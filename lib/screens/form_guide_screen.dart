import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/match.dart';
import '../core/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class FormGuideScreen extends StatelessWidget {
  const FormGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allMatches = context.watch<AppProvider>().matches.toList()..sort((a, b) => b.date.compareTo(a.date));

    // Filter matches from last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final matches = allMatches.where((m) {
      try {
        final matchDate = DateTime.parse(m.date);
        return matchDate.isAfter(thirtyDaysAgo);
      } catch (e) {
        return true;
      }
    }).toList();

    if (matches.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text('Form Guide', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
          centerTitle: true,
          elevation: 0,
          bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
        ),
        body: Center(
          child: Text('No matches in the last 30 days', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
        ),
      );
    }

    final homeMatches = matches.where((m) => _isHomeMatch(m)).toList();
    final awayMatches = matches.where((m) => !_isHomeMatch(m)).toList();
    final wins = matches.where((m) => m.result == 'Win').length;
    final draws = matches.where((m) => m.result == 'Draw').length;
    final losses = matches.where((m) => m.result == 'Loss').length;
    final winRate = matches.isEmpty ? 0 : ((wins / matches.length) * 100).toStringAsFixed(1);
    final homeWinRate = homeMatches.isEmpty ? 0 : ((homeMatches.where((m) => m.result == 'Win').length / homeMatches.length) * 100).toStringAsFixed(1);
    final awayWinRate = awayMatches.isEmpty ? 0 : ((awayMatches.where((m) => m.result == 'Win').length / awayMatches.length) * 100).toStringAsFixed(1);
    final avgRating = matches.isEmpty ? 0 : (matches.fold<int>(0, (s, m) => s + m.rating) ~/ matches.length);
    final totalGoals = matches.fold<int>(0, (s, m) => s + m.goals);
    final totalAssists = matches.fold<int>(0, (s, m) => s + m.assists);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Form Guide', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        centerTitle: true,
        elevation: 0,
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.outlineVariant)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Overall Form Card
          _buildStatCard(
            title: 'Overall Form',
            stats: [
              ('Record', '$wins-$draws-$losses'),
              ('Win Rate', '$winRate%'),
              ('Avg Rating', '$avgRating/10'),
            ],
          ),
          const SizedBox(height: 16),

          // Goals & Assists
          Row(
            children: [
              Expanded(
                child: _buildSmallStatCard(
                  icon: Icons.sports_soccer,
                  value: totalGoals.toString(),
                  label: 'Goals',
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallStatCard(
                  icon: Icons.handshake_outlined,
                  value: totalAssists.toString(),
                  label: 'Assists',
                  color: AppColors.secondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Home vs Away
          _buildComparisonCard(
            'Home vs Away',
            [
              ('Home Win Rate', '$homeWinRate%', AppColors.primaryContainer),
              ('Away Win Rate', '$awayWinRate%', AppColors.secondaryContainer),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Matches
          Text('Recent Matches',
              style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
          const SizedBox(height: 12),
          ...matches.take(5).map((m) => _buildMatchTile(m)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required List<(String, String)> stats}) {
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
          Text(title, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats.map((stat) {
              return Column(
                children: [
                  Text(stat.$2, style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(stat.$1, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({required IconData icon, required String value, required String label, required Color color}) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, List<(String, String, Color)> items) {
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
          Text(title, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(item.$1, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: item.$3, borderRadius: BorderRadius.circular(6)),
                    child: Text(item.$2, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMatchTile(Match m) {
    final resultColor = m.result == 'Win'
        ? const Color(0xFF10B981)
        : m.result == 'Loss'
            ? AppColors.error
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: resultColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                m.result == 'Win' ? 'W' : m.result == 'Loss' ? 'L' : 'D',
                style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: resultColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m.homeTeam} ${m.homeScore} - ${m.awayScore} ${m.opponent}',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
                const SizedBox(height: 4),
                Text('${m.goals}G ${m.assists}A • ${m.rating}/10',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(m.date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  bool _isHomeMatch(Match m) => m.homeTeam.isNotEmpty && m.homeTeam == (m.homeTeam);
}
