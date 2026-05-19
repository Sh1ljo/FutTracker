import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/training_session.dart';
import '../models/match.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 1; // 0=Week, 1=Month, 2=All Time

  DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _last4WeekStarts() {
    final currentWeek = _startOfWeek(DateTime.now());
    return List.generate(
      4,
      (i) => currentWeek.subtract(Duration(days: (3 - i) * 7)),
    );
  }

  int _weeklyTrainingMinutes(
      List<TrainingSession> sessions, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return sessions.where((s) {
      final d = DateTime.tryParse(s.date);
      return d != null && !d.isBefore(weekStart) && d.isBefore(weekEnd);
    }).fold(0, (sum, s) => sum + s.duration);
  }

  double _weeklyAverageRating(List<Match> matches, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekMatches = matches.where((m) {
      final d = DateTime.tryParse(m.date);
      return d != null && !d.isBefore(weekStart) && d.isBefore(weekEnd);
    }).toList();
    if (weekMatches.isEmpty) return 0;
    return weekMatches.fold<double>(0, (sum, m) => sum + m.rating) /
        weekMatches.length;
  }

  double _weeklyGoalContribution(List<Match> matches, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekMatches = matches.where((m) {
      final d = DateTime.tryParse(m.date);
      return d != null && !d.isBefore(weekStart) && d.isBefore(weekEnd);
    }).toList();
    if (weekMatches.isEmpty) return 0;
    return weekMatches.fold<double>(0, (sum, m) => sum + m.goals + m.assists) /
        weekMatches.length;
  }

  String _trendLabel(num current, num previous,
      {String suffix = '', bool higherIsBetter = true}) {
    final diff = current - previous;
    if (diff.abs() < 0.01) return 'Stable';
    final direction = diff > 0 ? 'up' : 'down';
    final value = diff.abs().toStringAsFixed(suffix.isEmpty ? 0 : 1);
    final positive = higherIsBetter ? diff > 0 : diff < 0;
    return '${positive ? 'Improving' : 'Declining'} · $direction $value$suffix';
  }

  List<String> _buildInsights({
    required List<TrainingSession> allSessions,
    required List<Match> allMatches,
    required int thisWeekSessions,
    required int weeklyGoal,
    required double avgIntensity,
    required double avgRating,
    required double ratingGoal,
    required int focusSkillHits,
    required int focusSkillGoal,
    required String focusSkill,
  }) {
    final insights = <String>[];

    if (thisWeekSessions < weeklyGoal) {
      insights.add(
          'You are ${weeklyGoal - thisWeekSessions} sessions from your weekly target. Plan one extra session this week.');
    } else {
      insights.add('Great consistency — weekly training target achieved.');
    }

    if (avgIntensity >= 4 && thisWeekSessions >= 3) {
      insights.add(
          'Your recent load is high (intensity ${avgIntensity.toStringAsFixed(1)}/5). Add a recovery session to avoid fatigue.');
    }

    if (allMatches.isNotEmpty) {
      if (avgRating < ratingGoal) {
        insights.add(
            'Average rating is ${avgRating.toStringAsFixed(1)} vs goal ${ratingGoal.toStringAsFixed(1)}. Focus on your strongest role actions next match.');
      } else {
        insights.add(
            'Match rating goal is on track (${avgRating.toStringAsFixed(1)} / ${ratingGoal.toStringAsFixed(1)}). Keep current preparation routine.');
      }
    }

    if (focusSkillGoal > 0) {
      if (focusSkillHits < focusSkillGoal) {
        insights.add(
            'Skill focus "$focusSkill" appears in $focusSkillHits/$focusSkillGoal sessions this week — add it in your next training.');
      } else {
        insights.add(
            'Skill focus "$focusSkill" target achieved this week. Build on it in match situations.');
      }
    }

    return insights.take(3).toList();
  }

  // Filter sessions & matches to the selected period
  DateTime get _cutoff {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0:
        return now.subtract(const Duration(days: 7));
      case 1:
        return now.subtract(const Duration(days: 30));
      default:
        return DateTime(2000);
    }
  }

  List<TrainingSession> _filterSessions(List<TrainingSession> all) {
    final cut = _cutoff;
    return all.where((s) {
      final d = DateTime.tryParse(s.date);
      return d != null && !d.isBefore(cut);
    }).toList();
  }

  List<Match> _filterMatches(List<Match> all) {
    final cut = _cutoff;
    return all.where((m) {
      final d = DateTime.tryParse(m.date);
      return d != null && !d.isBefore(cut);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sessions = _filterSessions(provider.sessions);
    final matches = _filterMatches(provider.matches);
    final allSessions = provider.sessions;
    final allMatches = provider.matches;

    // Compute stats from filtered data
    final totalGoals = matches.fold(0, (sum, m) => sum + m.goals);
    final totalAssists = matches.fold(0, (sum, m) => sum + m.assists);
    final totalTrainings = sessions.length;
    final totalTrainingMins = sessions.fold(0, (sum, s) => sum + s.duration);
    final avgIntensity = sessions.isEmpty
        ? 0.0
        : sessions.fold(0.0, (sum, s) => sum + s.intensity) / sessions.length;
    final totalDistanceKm =
        sessions.fold(0.0, (sum, s) => sum + (s.distance ?? 0.0));
    final totalCalories =
        sessions.fold(0, (sum, s) => sum + (s.caloriesBurned ?? 0));

    final weekStarts = _last4WeekStarts();
    final weeklyTrainingMins4w =
        weekStarts.map((w) => _weeklyTrainingMinutes(allSessions, w)).toList();
    final weeklyAvgRating4w =
        weekStarts.map((w) => _weeklyAverageRating(allMatches, w)).toList();
    final weeklyGA4w =
        weekStarts.map((w) => _weeklyGoalContribution(allMatches, w)).toList();

    final thisWeekStart = _startOfWeek(DateTime.now());
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 7));
    final thisWeekSessions = allSessions.where((s) {
      final d = DateTime.tryParse(s.date);
      return d != null && !d.isBefore(thisWeekStart) && d.isBefore(thisWeekEnd);
    }).length;

    final thisMonthMatches = allMatches.where((m) {
      final d = DateTime.tryParse(m.date);
      if (d == null) return false;
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month;
    }).toList();
    final avgRatingThisMonth = thisMonthMatches.isEmpty
        ? 0.0
        : thisMonthMatches.fold<double>(0, (sum, m) => sum + m.rating) /
            thisMonthMatches.length;

    final focusSkill = provider.profileFocusSkill;
    final focusSkillHits = allSessions.where((s) {
      final d = DateTime.tryParse(s.date);
      if (d == null || d.isBefore(thisWeekStart) || !d.isBefore(thisWeekEnd)) {
        return false;
      }
      return s.focusAreaList
          .map((e) => e.toLowerCase())
          .contains(focusSkill.toLowerCase());
    }).length;

    final insights = _buildInsights(
      allSessions: allSessions,
      allMatches: allMatches,
      thisWeekSessions: thisWeekSessions,
      weeklyGoal: provider.profileWeeklyGoal,
      avgIntensity: avgIntensity,
      avgRating: avgRatingThisMonth,
      ratingGoal: provider.profileAvgRatingGoal,
      focusSkillHits: focusSkillHits,
      focusSkillGoal: provider.profileFocusSkillSessionsGoal,
      focusSkill: focusSkill,
    );

    // Weekly volume (always last 7 days, regardless of period selector)
    final weeklyData = _buildWeeklyData(provider.sessions);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('Performance Stats',
                style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.primary),
                onPressed: () {},
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.outlineVariant),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPeriodSelector(),
                const SizedBox(height: 20),
                _buildSummaryBanner(sessions, matches),
                const SizedBox(height: 16),
                _buildTrendSection(
                  minsCurrent: weeklyTrainingMins4w[3],
                  minsPrevious: weeklyTrainingMins4w[2],
                  ratingCurrent: weeklyAvgRating4w[3],
                  ratingPrevious: weeklyAvgRating4w[2],
                  gaCurrent: weeklyGA4w[3],
                  gaPrevious: weeklyGA4w[2],
                ),
                const SizedBox(height: 16),
                _buildGoalProgressCard(
                  weeklyGoal: provider.profileWeeklyGoal,
                  thisWeekSessions: thisWeekSessions,
                  avgRatingGoal: provider.profileAvgRatingGoal,
                  avgRatingThisMonth: avgRatingThisMonth,
                  focusSkill: focusSkill,
                  focusSkillGoal: provider.profileFocusSkillSessionsGoal,
                  focusSkillHits: focusSkillHits,
                ),
                const SizedBox(height: 16),
                _buildActionableInsightsCard(insights),
                const SizedBox(height: 16),
                _buildMetricGrid(totalGoals, totalAssists, totalTrainings,
                    totalTrainingMins, totalDistanceKm, totalCalories),
                const SizedBox(height: 20),
                _buildTrainingVolumeChart(weeklyData),
                const SizedBox(height: 20),
                _buildAvgIntensityCard(avgIntensity),
                const SizedBox(height: 20),
                _buildMatchHighlights(matches),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _buildWeeklyData(List<TrainingSession> allSessions) {
    final data = <String, int>{};
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final mins = allSessions
          .where((s) => s.date == dateStr)
          .fold(0, (sum, s) => sum + s.duration);
      data[days[(day.weekday - 1) % 7]] = mins;
    }
    return data;
  }

  Widget _buildPeriodSelector() {
    final labels = ['This Week', 'This Month', 'All Time'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter by period',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: labels.asMap().entries.map((e) {
              final selected = _selectedPeriod == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4)
                            ]
                          : [],
                    ),
                    child: Text(
                      e.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(
      List<TrainingSession> sessions, List<Match> matches) {
    final periodLabel =
        ['this week', 'this month', 'all time'][_selectedPeriod];
    final wins = matches.where((m) => m.result == 'Win').length;
    final winRate =
        matches.isEmpty ? 0 : ((wins / matches.length) * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bannerStat('${sessions.length}', 'Sessions', periodLabel),
          _bannerDivider(),
          _bannerStat('${matches.length}', 'Matches', periodLabel),
          _bannerDivider(),
          _bannerStat('$winRate%', 'Win Rate', periodLabel),
        ],
      ),
    );
  }

  Widget _buildTrendSection({
    required int minsCurrent,
    required int minsPrevious,
    required double ratingCurrent,
    required double ratingPrevious,
    required double gaCurrent,
    required double gaPrevious,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('4-Week Trends',
              style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          const SizedBox(height: 12),
          _trendTile(
            'Training Minutes',
            '$minsCurrent',
            _trendLabel(minsCurrent, minsPrevious, suffix: 'm'),
            minsCurrent >= minsPrevious,
          ),
          const SizedBox(height: 8),
          _trendTile(
            'Avg Match Rating',
            ratingCurrent == 0 ? '—' : ratingCurrent.toStringAsFixed(1),
            _trendLabel(ratingCurrent, ratingPrevious),
            ratingCurrent >= ratingPrevious,
          ),
          const SizedBox(height: 8),
          _trendTile(
            'Goals + Assists / Match',
            gaCurrent == 0 ? '—' : gaCurrent.toStringAsFixed(1),
            _trendLabel(gaCurrent, gaPrevious),
            gaCurrent >= gaPrevious,
          ),
        ],
      ),
    );
  }

  Widget _trendTile(
      String title, String value, String subtitle, bool positive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            size: 18,
            color: positive ? AppColors.primaryContainer : AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground)),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.onSurfaceVariant)),
            ]),
          ),
          Text(value,
              style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard({
    required int weeklyGoal,
    required int thisWeekSessions,
    required double avgRatingGoal,
    required double avgRatingThisMonth,
    required String focusSkill,
    required int focusSkillGoal,
    required int focusSkillHits,
  }) {
    final weeklyRatio =
        weeklyGoal > 0 ? (thisWeekSessions / weeklyGoal).clamp(0.0, 1.0) : 0.0;
    final ratingRatio = avgRatingGoal > 0
        ? (avgRatingThisMonth / avgRatingGoal).clamp(0.0, 1.0)
        : 0.0;
    final skillRatio = focusSkillGoal > 0
        ? (focusSkillHits / focusSkillGoal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Goal Progress',
            style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground)),
        const SizedBox(height: 12),
        _goalRow(
            'Weekly Sessions', '$thisWeekSessions/$weeklyGoal', weeklyRatio),
        const SizedBox(height: 10),
        _goalRow(
            'Avg Rating This Month',
            '${avgRatingThisMonth == 0 ? '—' : avgRatingThisMonth.toStringAsFixed(1)}/${avgRatingGoal.toStringAsFixed(1)}',
            ratingRatio),
        const SizedBox(height: 10),
        _goalRow('Focus Skill: $focusSkill', '$focusSkillHits/$focusSkillGoal',
            skillRatio),
      ]),
    );
  }

  Widget _goalRow(String label, String value, double progress) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
        ),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          minHeight: 7,
          value: progress,
          backgroundColor: AppColors.surfaceContainerHigh,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
        ),
      ),
    ]);
  }

  Widget _buildActionableInsightsCard(List<String> insights) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Actionable Insights',
            style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground)),
        const SizedBox(height: 10),
        ...insights.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.tips_and_updates_outlined,
                        size: 15, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tip,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
            )),
      ]),
    );
  }

  Widget _bannerStat(String value, String label, String sub) {
    return Column(children: [
      Text(value,
          style: GoogleFonts.lexend(
              fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(220))),
    ]);
  }

  Widget _bannerDivider() =>
      Container(width: 1, height: 40, color: Colors.white.withAlpha(50));

  Widget _buildMetricGrid(int goals, int assists, int trainings,
      int trainingMins, double distKm, int calories) {
    final items = [
      {
        'icon': Icons.sports_soccer,
        'label': 'Goals',
        'value': '$goals',
        'sub': ''
      },
      {
        'icon': Icons.group_outlined,
        'label': 'Assists',
        'value': '$assists',
        'sub': ''
      },
      {
        'icon': Icons.event_note_outlined,
        'label': 'Sessions',
        'value': '$trainings',
        'sub': ''
      },
      {
        'icon': Icons.timer_outlined,
        'label': 'Train. Time',
        'value': (trainingMins / 60).toStringAsFixed(1),
        'sub': 'hrs'
      },
      {
        'icon': Icons.directions_run_outlined,
        'label': 'Distance',
        'value': distKm.toStringAsFixed(1),
        'sub': 'km'
      },
      {
        'icon': Icons.local_fire_department_outlined,
        'label': 'Calories',
        'value': '$calories',
        'sub': 'kcal'
      },
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: items.map((item) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item['icon'] as IconData,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(item['value'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBackground)),
                  ),
                  if ((item['sub'] as String).isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(item['sub'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text((item['label'] as String).toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrainingVolumeChart(Map<String, int> weeklyData) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = days.map((d) => weeklyData[d] ?? 0).toList();
    final maxVal = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final todayIdx = (DateTime.now().weekday - 1) % 7;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Weekly Volume',
                style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground)),
            Text('mins / day',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['$maxVal', '${maxVal ~/ 2}', '0']
                      .map((v) => Text(v,
                          style: GoogleFonts.inter(
                              fontSize: 10, color: AppColors.onSurfaceVariant)))
                      .toList(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (i) {
                            final ratio = maxVal > 0 ? values[i] / maxVal : 0.0;
                            final isToday = i == todayIdx;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: AnimatedContainer(
                                  duration:
                                      Duration(milliseconds: 400 + i * 60),
                                  curve: Curves.easeOut,
                                  height: 110 * ratio + (ratio > 0 ? 4 : 4),
                                  decoration: BoxDecoration(
                                    gradient: isToday
                                        ? const LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              AppColors.primaryContainer,
                                              Color(0xFF34D399)
                                            ],
                                          )
                                        : null,
                                    color: isToday
                                        ? null
                                        : AppColors.primary
                                            .withValues(alpha: 0.25),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(7, (i) {
                          final isToday = i == todayIdx;
                          return Expanded(
                            child: Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w400,
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvgIntensityCard(double avgIntensity) {
    final pct = (avgIntensity / 5).clamp(0.0, 1.0);
    final label = avgIntensity == 0
        ? 'No data for this period'
        : avgIntensity < 2
            ? 'Light — mostly recovery work'
            : avgIntensity < 3
                ? 'Moderate — good balance'
                : avgIntensity < 4
                    ? 'High — pushing hard'
                    : 'Very High — watch your load!';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Avg Training Intensity',
              style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          const SizedBox(height: 16),
          Row(children: [
            Text(avgIntensity == 0 ? '—' : avgIntensity.toStringAsFixed(1),
                style: GoogleFonts.lexend(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text(' / 5',
                style: GoogleFonts.inter(
                    fontSize: 16, color: AppColors.onSurfaceVariant)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryContainer),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMatchHighlights(List<Match> matches) {
    if (matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: Column(children: [
            const Icon(Icons.sports_soccer_outlined,
                size: 36, color: AppColors.outlineVariant),
            const SizedBox(height: 8),
            Text('No matches in this period',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ]),
        ),
      );
    }

    final wins = matches.where((m) => m.result == 'Win').length;
    final draws = matches.where((m) => m.result == 'Draw').length;
    final losses = matches.where((m) => m.result == 'Loss').length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Match Record',
              style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          const SizedBox(height: 16),
          // W-D-L record
          Row(
            children: [
              _recordBox('$wins', 'W', AppColors.primaryContainer,
                  const Color(0xFFDCFCE7)),
              const SizedBox(width: 10),
              _recordBox('$draws', 'D', AppColors.outline,
                  AppColors.surfaceContainerHigh),
              const SizedBox(width: 10),
              _recordBox(
                  '$losses', 'L', AppColors.error, AppColors.errorContainer),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          // Recent matches
          ...matches.take(3).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: m.result == 'Win'
                          ? const Color(0xFFDCFCE7)
                          : m.result == 'Loss'
                              ? AppColors.errorContainer
                              : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(m.result,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: m.result == 'Win'
                                ? AppColors.primaryContainer
                                : m.result == 'Loss'
                                    ? AppColors.error
                                    : AppColors.outline)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        '${m.homeTeam} ${m.homeScore}–${m.awayScore} ${m.opponent}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground)),
                  ),
                  Text('${m.goals}G ${m.assists}A',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ]),
              )),
        ],
      ),
    );
  }

  Widget _recordBox(
      String value, String label, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.lexend(
                  fontSize: 28, fontWeight: FontWeight.w700, color: textColor)),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
        ]),
      ),
    );
  }
}
