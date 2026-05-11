import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class FormGuideScreen extends StatefulWidget {
  const FormGuideScreen({super.key});

  @override
  State<FormGuideScreen> createState() => _FormGuideScreenState();
}

class _FormGuideScreenState extends State<FormGuideScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom on init to see latest matches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<AppProvider>().matches
        .toTypedList()
        .where((m) => m.date!.isAfter(DateTime.now().subtract(const Duration(days: 30))));

    // Calculate home/away stats
    final homeMatches = matches.where((m) => _isHomeMatch(m));
    final awayMatches = matches.where((m) => !_isHomeMatch(m));
    final homeWinRate = _calculateWinRate(homeMatches);
    final awayWinRate = _calculateWinRate(awayMatches);
    final overallWinRate = _calculateWinRate(matches);

    // Calculate best opponents (based on performance)
    final bestOpponents = _getBestOpponents(matches);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('Form Guide',
                style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            centerTitle: true,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.outlineVariant),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Form Indicator
                _buildFormIndicatorSection(matches),
                const SizedBox(height: 24),

                // Home/Away Performance
                _buildHomeAwaySection(
                    homeWinRate, awayWinRate, homeMatches.length, awayMatches.length),
                const SizedBox(height: 24),

                // Recent Performance Chart
                _buildPerformanceChartSection(matches),
                const SizedBox(height: 24),

                // Best Opponents
                _buildBestOpponentsSection(bestOpponents),
                const SizedBox(height: 24),

                // Performance Breakdown
                _buildBreakdownSection(matches),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  bool _isHomeMatch(Match match) {
    // Assuming we're tracking for home team - adjust based on your data structure
    // For now, we'll use a simple heuristic - you may want to add a isHome field to Match model
    return match.homeTeam.length > match.opponent.length; // Simple heuristic
  }

  double _calculateWinRate(List<Match> matches) {
    if (matches.isEmpty) return 0;
    final wins = matches.where((m) => m.result == 'Win').length;
    return (wins / matches.length) * 100;
  }

  List<String> _getBestOpponents(List<Match> matches) {
    final opponentScores = <String, double>{};

    for (var match in matches) {
      final opponentName = match.opponent;
      if (opponentScores[opponentName] == null) {
        opponentScores[opponentName] = 0;
      }

      // Rate opponent by match difficulty (your performance)
      if (match.result == 'Win') {
        opponentScores[opponentName] = (opponentScores[opponentName]! + 8) * 0.95;
      } else if (match.result == 'Draw') {
        opponentScores[opponentName] = (opponentScores[opponentName]! + 5) * 0.98;
      } else if (match.result == 'Loss') {
        opponentScores[opponentName] = (opponentScores[opponentName]! + 2) * 1.0;
      }

      // Factor in quality of performance
      opponentScores[opponentName] =
          (opponentScores[opponentName]! + match.rating) * 0.05;
    }

    return opponentScores.entries
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => e.key)
        .toList();
  }

  // ─── Widget Builders ─────────────────────────────────────────────────────────
  Widget _buildFormIndicatorSection(List<Match> matches) {
    if (matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(Icons.trending_up_outlined,
                size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            Text('No matches yet',
                style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('Log some matches to see your form.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Last 5 matches form indicator (W-D-L-W-L pattern)
    final recentMatches = matches.take(5).toList().reversed.toList();
    final formString = recentMatches
        .map((m) => m.result == 'Win' ? 'W' : m.result == 'Draw' ? 'D' : 'L')
        .join('');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Form',
                  style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _formColor(formString),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(formString,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _formTextColor(formString))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Visual form indicator
          Row(
            children: recentMatches.map((m) => _buildFormDot(m)).toList(),
          ),
          const SizedBox(height: 16),
          Text('Last 5 matches',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          // Match list
          ...recentMatches.take(5).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(m.date ?? '???',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${m.homeTeam} ${m.homeScore} - ${m.awayScore} ${m.opponent}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onBackground))),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 40,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: Text(m.result,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _matchResultColor(m.result))),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFormDot(Match match) {
    return Container(
      width: 40,
      child: Column(
        children: [
          Icon(
            match.result == 'Win'
                ? Icons.check_circle
                : match.result == 'Draw'
                    ? Icons.draw_outlined
                    : Icons.close_circle_outlined,
            color: match.result == 'Win'
                ? AppColors.primary
                : match.result == 'Draw'
                    ? AppColors.secondary
                    : AppColors.error,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(match.result,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: match.result == 'Win'
                      ? AppColors.primary
                      : match.result == 'Draw'
                          ? AppColors.secondary
                          : AppColors.error)),
        ],
      ),
    );
  }

  Widget _buildHomeAwaySection(
      double homeWinRate,
      double awayWinRate,
      int homeMatches,
      int awayMatches) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Home vs Away Performance',
                  style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground)),
              if (homeMatches > 0 && awayMatches > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${homeMatches}H | ${awayMatches}A',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onPrimaryContainer)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Home bar
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Home',
                            style: GoogleFonts.lexend(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant)),
                        Text('${homeWinRate.toInt()}%',
                            style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: _ratingColor(
                                    (homeWinRate + awayWinRate) / 2))),
                      ],
                    ),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: homeMatches > 0 ? homeWinRate / 100 : 0,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                            AppColors.primaryContainer),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Away bar
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Away',
                            style: GoogleFonts.lexend(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant)),
                        Text('${awayWinRate.toInt()}%',
                            style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: _ratingColor(
                                    (homeWinRate + awayWinRate) / 2))),
                      ],
                    ),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: awayMatches > 0 ? awayWinRate / 100 : 0,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                            AppColors.primaryContainer),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (homeMatches > 0 && awayMatches > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (homeWinRate >= awayWinRate)
                        ? Icons.home_outlined
                        : Icons.chevron_right,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    (homeWinRate >= awayWinRate)
                        ? 'You perform better at home ⚽'
                        : 'You\'re more consistent away from home',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceChartSection(List<Match> matches) {
    if (matches.isEmpty) return const SizedBox();

    // Create a visual chart showing rating progression
    final chartMatches = matches.take(10).reversed.toList();
    final highestRating = chartMatches
        .fold<int>(0, (prev, m) => m.rating > prev ? m.rating : prev);
    final lowestRating = chartMatches
        .fold<int>(10, (prev, m) => m.rating < prev ? m.rating : prev);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Performance Trend',
                  style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground)),
              Text(
                'Avg: ${matches.length > 0 ? (matches.fold<int>(0, (s, m) => s + m.rating) ~/ matches.length)/10 * 10 : 0}/10',
                style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: _ratingColor(
                        matches.length > 0
                            ? (matches.fold<int>(0, (s, m) => s + m.rating) ~/
                                matches.length))
                            : 0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart bars
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: chartMatches.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Stack(
                            children: [
                              // Background bar
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Colored bar
                              Positioned(
                                right: 0,
                                child: Container(
                                  height: m.rating * 2,
                                  decoration: BoxDecoration(
                                    color: _ratingColor(m.rating),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(m.date),
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text('Rating progression over last matches',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                AppColors.primary,
                '7-8 rating',
                Icons.info_outline,
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                const Color(0xFF059669),
                '8+ rating',
                Icons.star,
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                const Color(0xFFEA4335),
                '4-6 rating',
                Icons.warning_amber_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestOpponentsSection(List<String> opponents) {
    if (opponents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Text('Not enough matches yet',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.onSurfaceVariant)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Opponent Ratings',
                  style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground)),
              Icon(Icons.assessment_outlined,
                  color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // Opponent rating bars
          ...opponents.asMap().entries.map((entry) {
            final index = entry.key;
            final opponent = entry.value;
            final rating = entry.value; // This won't work, need to fix logic
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shield,
                        color: AppColors.primary, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(opponent,
                        style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onBackground)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              rating.toStringAsFixed(1),
                              style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: _ratingColor(rating)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Text(
                                '${(rating * 0.05).toStringAsFixed(1)} pts',
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.onPrimaryContainer),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection(List<Match> matches) {
    if (matches.isEmpty) return const SizedBox();

    final totalGoals = matches.fold<int>(0, (s, m) => s + m.goals);
    final totalAssists = matches.fold<int>(0, (s, m) => s + m.assists);
    final totalPasses = matches.fold<int>(0, (s, m) => s + m.passes);
    final totalMinutes = matches.fold<int>(0, (s, m) => s + m.minutesPlayed);
    final totalRating = matches.fold<int>(0, (s, m) => s + m.rating);
    final avgRating = totalRating ~/ matches.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Statistics',
              style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 1.8,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _breakdownStat(Icons.sports_soccer, totalGoals.toString(), 'Goals'),
              _breakdownStat(Icons.group_outlined, totalAssists.toString(),
                  'Assists'),
              _breakdownStat(Icons.swap_horiz,
                  '${(totalPasses / matches.length).toStringAsFixed(1)}', 'Avg Passes'),
              _breakdownStat(Icons.timer_outlined,
                  '${totalMinutes ~/ matches.length}m', 'Avg Mins'),
              _breakdownStat(Icons.favorite, avgRating.toString(), 'Avg Rating'),
              _breakdownStat(Icons.check_circle,
                  '${matches.where((m) => m.result == 'Win').length}', 'Wins'),
              _breakdownStat(Icons.draw_outlined,
                  '${matches.where((m) => m.result == 'Draw').length}', 'Draws'),
              _breakdownStat(Icons.close_circle,
                  '${matches.where((m) => m.result == 'Loss').length}', 'Losses'),
            ],
          ),
          const SizedBox(height: 12),
          // Win percentage
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Win Rate',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      '${((matches.where((m) => m.result == 'Win').length / matches.length * 100)).toStringAsFixed(1)}%',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Matched',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      '${matches.length} matches',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownStat(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 4),
          Flexible(
            child: Text(value,
                style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground)),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: (color.value >= 0x663B53)
                    ? AppColors.onSurfaceVariant
                    : AppColors.onBackground)),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  Color _formColor(String form) {
    final wins = form.split('').where((c) => c == 'W').length;
    final draws = form.split('').where((c) => c == 'D').length;
    final losses = form.split('').where((c) => c == 'L').length;

    if (wins >= 3) return AppColors.primaryContainer;
    if (losses >= 3) return AppColors.errorContainer;
    if (draws == form.length) return AppColors.secondaryContainer;
    return AppColors.surfaceContainerLowest;
  }

  Color _formTextColor(String form) {
    final wins = form.split('').where((c) => c == 'W').length;
    return wins >= 3 ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant;
  }

  Color _matchResultColor(String result) {
    if (result == 'Win') return AppColors.primary;
    if (result == 'Loss') return AppColors.error;
    return AppColors.secondary;
  }

  Color _ratingColor(int rating) {
    if (rating >= 8) return const Color(0xFF059669);
    if (rating >= 6) return AppColors.primary;
    if (rating >= 4) return const Color(0xFFEA4335);
    return const Color(0xFF78736C);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '???';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1) {
      return 'Today';
    } else if (diff.inDays < 7) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
