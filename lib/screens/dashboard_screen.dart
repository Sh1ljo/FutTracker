import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/training_session.dart';
import '../models/match.dart';
import 'add_training_screen.dart';
import 'add_match_screen.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int tabIndex)? onSwitchTab;
  const DashboardScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sessions = provider.sessions;
    final matches = provider.matches;
    final name = provider.profileName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, provider),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcome(context, name),
                const SizedBox(height: 16),
                _buildLogTrainingButton(context),
                const SizedBox(height: 10),
                _buildLogMatchButton(context),
                const SizedBox(height: 24),
                _buildWeeklyLoadCard(context, sessions),
                const SizedBox(height: 24),
                _buildRecentActivity(
                    context, sessions, matches, provider.trainingStreak),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppProvider provider) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.secondaryContainer,
            child: Text(
                provider.profileName.isNotEmpty
                    ? provider.profileName[0].toUpperCase()
                    : 'A',
                style: GoogleFonts.lexend(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Text('FutTracker',
              style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ],
      ),
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
    );
  }

  Widget _buildWelcome(BuildContext context, String firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back, $firstName',
            style: GoogleFonts.lexend(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Ready to crush your goals today?',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildLogTrainingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTrainingScreen()),
        ),
        icon: const Icon(Icons.add_circle, color: Colors.white),
        label: Text('Log Training',
            style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildLogMatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMatchScreen()),
        ),
        icon: const Icon(Icons.sports_soccer, color: AppColors.primary),
        label: Text('Log Match',
            style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildWeeklyLoadCard(
      BuildContext context, List<TrainingSession> sessions) {
    final now = DateTime.now();
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final durations = List<int>.filled(7, 0);
    for (final s in sessions) {
      final date = DateTime.tryParse(s.date);
      if (date == null) continue;
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        final idx = 6 - diff;
        durations[idx] += s.duration;
      }
    }
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Load',
              style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio =
                    maxDuration > 0 ? durations[i] / maxDuration : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 72 * ratio + (ratio > 0 ? 4 : 4),
                          decoration: BoxDecoration(
                            color: i == 6
                                ? AppColors.primaryContainer
                                : AppColors.primary.withValues(alpha: 0.35),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dayLabels[i],
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight:
                                    i == 6 ? FontWeight.w700 : FontWeight.w400,
                                color: i == 6
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    List<TrainingSession> sessions,
    List<Match> matches,
    int streak,
  ) {
    // Build a unified list sorted newest-first
    final items = <Map<String, dynamic>>[
      ...sessions.map((s) => {
            'date': s.date,
            'title': s.trainingType ??
                (s.location?.isNotEmpty == true
                    ? s.location!
                    : 'Training Session'),
            'subtitle':
                '${s.intensityLabel} · ${s.duration} mins${s.distance != null ? ' · ${s.distance!.toStringAsFixed(1)} km' : ''}',
            'tag': s.trainingType ?? s.intensityLabel,
            'tagColor': AppColors.secondaryContainer,
            'tagTextColor': AppColors.primary,
            'icon': Icons.fitness_center_outlined,
            'iconBg': AppColors.secondaryContainer,
          }),
      ...matches.map((m) => {
            'date': m.date,
            'title': '${m.homeTeam} vs ${m.opponent}',
            'subtitle':
                '${m.homeScore}–${m.awayScore} · ${m.goals}G ${m.assists}A · ${m.minutesPlayed} mins',
            'tag': m.result,
            'tagColor': m.result == 'Win'
                ? const Color(0xFFDCFCE7)
                : m.result == 'Loss'
                    ? AppColors.errorContainer
                    : AppColors.surfaceContainerHigh,
            'tagTextColor': m.result == 'Win'
                ? AppColors.primaryContainer
                : m.result == 'Loss'
                    ? AppColors.error
                    : AppColors.outline,
            'icon': Icons.sports_soccer_outlined,
            'iconBg': AppColors.surfaceContainerHigh,
          }),
    ]..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

    final recent = items.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Activity',
                        style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground)),
                    if (streak > 0)
                      Row(children: [
                        const Icon(Icons.local_fire_department,
                            size: 14, color: Color(0xFFEA580C)),
                        const SizedBox(width: 3),
                        Text('$streak-day streak',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEA580C))),
                      ]),
                  ],
                ),
                TextButton(
                  onPressed: () => onSwitchTab?.call(1),
                  child: Text('View All',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No recent activity',
                  style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
            )
          else
            ...recent.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item['iconBg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onBackground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(item['subtitle'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item['tagColor'] as Color,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(item['tag'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: item['tagTextColor'] as Color)),
                        ),
                        const SizedBox(height: 2),
                        Text(item['date'] as String,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ]),
                ),
                if (i < recent.length - 1)
                  const Divider(height: 1, color: AppColors.outlineVariant),
              ]);
            }),
        ],
      ),
    );
  }
}
