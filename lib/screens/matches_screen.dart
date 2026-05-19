import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/match.dart';
import 'add_match_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<AppProvider>().matches;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('Matches',
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
                _buildAddMatchButton(context),
                if (matches.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildRatingChart(context, matches),
                ],
                Text('Match History',
                    style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground)),
                const SizedBox(height: 12),
                if (matches.isEmpty)
                  _buildEmpty()
                else
                  ...matches.map((m) => _buildMatchCard(context, m)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddMatchScreen())),
        icon: const Icon(Icons.sports_soccer, color: Colors.white),
        label: Text('Log Match',
            style: GoogleFonts.lexend(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_soccer_outlined,
              size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Text('No matches yet',
              style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Tap "Log Match" to record your first game.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match) {
    final resultColor = match.result == 'Win'
        ? AppColors.primaryContainer
        : match.result == 'Loss'
            ? AppColors.error
            : AppColors.outline;

    final resultBg = match.result == 'Win'
        ? const Color(0xFFDCFCE7)
        : match.result == 'Loss'
            ? AppColors.errorContainer
            : AppColors.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => MatchDetailScreen(match: match))),
        onLongPress: () => _showOptions(context, match),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Score row
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(match.homeTeam,
                            style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onBackground)),
                      ],
                    ),
                  ),
                  // Score
                  Column(
                    children: [
                      Text('${match.homeScore} - ${match.awayScore}',
                          style: GoogleFonts.lexend(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: resultBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(match.result,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: resultColor)),
                      ),
                    ],
                  ),
                  // Away team
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_outlined,
                              color: AppColors.onSurfaceVariant, size: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(match.opponent,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onBackground)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 10),
              // My stats strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip(Icons.sports_soccer, '${match.goals}', 'Goals'),
                  _statChip(Icons.group, '${match.assists}', 'Assists'),
                  _statChip(Icons.swap_horiz, '${match.passes}', 'Passes'),
                  _statChip(
                      Icons.timer_outlined, '${match.minutesPlayed}', 'Mins'),
                ],
              ),
              const SizedBox(height: 4),
              Text(match.date,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.onSurfaceVariant)),
              // Rating indicator
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rating',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant)),
                  Text('${match.rating}/10',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _ratingColor(match.rating))),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Container(
                      width: constraints.maxWidth * (match.rating / 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _ratingGradient(match.rating),
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildRatingChart(BuildContext context, List<Match> matches) {
    final recentMatches = matches.take(10).toList();
    final avgRating = recentMatches.fold<int>(
          0,
          (sum, m) => sum + m.rating,
        ) ~/
        recentMatches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Performance Trend',
                style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground)),
            Text('Recent: ${recentMatches.length} matches',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Average Rating',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('$avgRating/10',
                        style: GoogleFonts.lexend(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: _ratingColor(avgRating))),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: recentMatches
                      .map((m) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 8,
                                  height: 20 + (m.rating * 3),
                                  decoration: BoxDecoration(
                                    color: _ratingColor(m.rating),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _ratingColor(int rating) {
    if (rating >= 8) return const Color(0xFF059669);
    if (rating >= 6) return AppColors.primary;
    if (rating >= 4) return const Color(0xFFEA4335);
    return const Color(0xFF78736C);
  }

  List<Color> _ratingGradient(int rating) {
    if (rating >= 8) return [const Color(0xFF059669), const Color(0xFF059669)];
    if (rating >= 6) return [AppColors.primary, AppColors.primary];
    if (rating >= 4) return [const Color(0xFFEA4335), const Color(0xFFEA4335)];
    return [const Color(0xFF78736C), const Color(0xFF78736C)];
  }

  void _showDeleteDialog(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Match',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
        content: Text('Remove match vs ${match.opponent}?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().deleteMatch(match.id!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, Match match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: Text('Edit Match',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddMatchScreen(existing: match)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('Delete Match',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, match);
            },
          ),
        ]),
      ),
    );
  }
}

// ─── Match Detail Screen ──────────────────────────────────────────────────────

class MatchDetailScreen extends StatelessWidget {
  final Match match;
  const MatchDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final resultColor = match.result == 'Win'
        ? AppColors.primaryContainer
        : match.result == 'Loss'
            ? AppColors.error
            : AppColors.outline;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Match Detail',
            style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit Match',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => AddMatchScreen(existing: match)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Match',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text('Delete Match',
                      style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                  content: Text('Remove match vs ${match.opponent}?',
                      style: GoogleFonts.inter()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel',
                          style: GoogleFonts.inter(
                              color: AppColors.onSurfaceVariant)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AppProvider>().deleteMatch(match.id!);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white),
                      child: Text('Delete', style: GoogleFonts.inter()),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Live Score',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _teamCol(match.homeTeam, true),
                      Column(
                        children: [
                          Text('${match.homeScore} - ${match.awayScore}',
                              style: GoogleFonts.lexend(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onBackground)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: match.result == 'Win'
                                  ? const Color(0xFFDCFCE7)
                                  : match.result == 'Loss'
                                      ? AppColors.errorContainer
                                      : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(match.result,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: resultColor)),
                          ),
                        ],
                      ),
                      _teamCol(match.opponent, false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(match.date,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // My Performance
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Performance',
                      style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _perfCard(Icons.sports_soccer, '${match.goals}', 'Goals'),
                      _perfCard(
                          Icons.group_outlined, '${match.assists}', 'Assists'),
                      _perfCard(Icons.swap_horiz, '${match.passes}', 'Passes'),
                      _perfCard(
                          Icons.sports_kabaddi, '${match.tackles}', 'Tackles'),
                      _perfCard(Icons.timer_outlined, '${match.minutesPlayed}',
                          'Minutes'),
                    ],
                  ),
                ],
              ),
            ),
            if (match.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Post-Game Notes',
                        style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground)),
                    const SizedBox(height: 10),
                    Text(match.notes!,
                        style: GoogleFonts.inter(
                            fontSize: 15, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _teamCol(String name, bool isHome) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isHome
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHome ? Icons.shield : Icons.shield_outlined,
            color: isHome ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(name,
            style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground)),
      ],
    );
  }

  Widget _perfCard(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: AppColors.primary, size: 15),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground)),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 9, color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
