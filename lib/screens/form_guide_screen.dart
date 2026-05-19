import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/match.dart';
import '../models/training_session.dart';
import '../core/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;

class FormGuideScreen extends StatefulWidget {
  const FormGuideScreen({super.key});

  @override
  State<FormGuideScreen> createState() => _FormGuideScreenState();
}

class _FormGuideScreenState extends State<FormGuideScreen> {
  bool _isFormulaExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allMatches = provider.matches.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final allSessions = provider.sessions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

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

    final sessions = allSessions.where((s) {
      try {
        final sessionDate = DateTime.parse(s.date);
        return sessionDate.isAfter(thirtyDaysAgo);
      } catch (e) {
        return true;
      }
    }).toList();

    if (matches.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text('Form Guide',
              style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          centerTitle: true,
          elevation: 0,
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
        ),
        body: Center(
          child: Text('No matches in the last 30 days',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
        ),
      );
    }

    final homeMatches =
        matches.where((m) => _isHomeMatch(m, provider)).toList();
    final awayMatches =
        matches.where((m) => !_isHomeMatch(m, provider)).toList();
    final wins = matches.where((m) => m.result == 'Win').length;
    final draws = matches.where((m) => m.result == 'Draw').length;
    final losses = matches.where((m) => m.result == 'Loss').length;
    final winRate = matches.isEmpty
        ? '0'
        : ((wins / matches.length) * 100).toStringAsFixed(1);
    final homeWinRate = homeMatches.isEmpty
        ? '0'
        : ((homeMatches.where((m) => m.result == 'Win').length /
                    homeMatches.length) *
                100)
            .toStringAsFixed(1);
    final awayWinRate = awayMatches.isEmpty
        ? '0'
        : ((awayMatches.where((m) => m.result == 'Win').length /
                    awayMatches.length) *
                100)
            .toStringAsFixed(1);
    final totalGoals = matches.fold<int>(0, (s, m) => s + m.goals);
    final totalAssists = matches.fold<int>(0, (s, m) => s + m.assists);
    final avgForm = _calculateAverageForm(matches, sessions);

    // Weekly training goal progress
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    final thisWeekSessions =
        sessions.where((s) => s.date.compareTo(weekStartDate) >= 0).length;
    final weeklyGoal = provider.profileWeeklyGoal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Form Guide',
            style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        centerTitle: true,
        elevation: 0,
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Form Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Form',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(avgForm.toStringAsFixed(1),
                          style: GoogleFonts.lexend(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Text('/10.0',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Training Goal Progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Training Progress',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: weeklyGoal > 0
                              ? (thisWeekSessions / weeklyGoal).clamp(0, 1)
                              : 0,
                          backgroundColor:
                              AppColors.outlineVariant.withAlpha(40),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            thisWeekSessions >= weeklyGoal
                                ? Colors.green
                                : AppColors.primary,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$thisWeekSessions/$weeklyGoal',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: thisWeekSessions >= weeklyGoal
                                  ? Colors.green
                                  : AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Form History (Last 30 Days)',
                            style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 2,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text('7-day avg',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildFormChart(matches, sessions),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Match Results Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Match Results',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox('Wins', wins.toString(), Colors.green),
                      _buildStatBox('Draws', draws.toString(), Colors.grey),
                      _buildStatBox('Losses', losses.toString(), Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Win Rates
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Win Rate',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWinRateBox('Overall', '$winRate%'),
                      _buildWinRateBox('Home', '$homeWinRate%'),
                      _buildWinRateBox('Away', '$awayWinRate%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Stats',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox(
                          'Goals', totalGoals.toString(), AppColors.primary),
                      _buildStatBox('Assists', totalAssists.toString(),
                          AppColors.secondary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Training Type Effectiveness
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Training Type Effectiveness',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  _buildTrainingEffectiveness(matches, sessions),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Formula Explanation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFormulaExpanded = !_isFormulaExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('How Form is Calculated',
                            style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface)),
                        Icon(_isFormulaExpanded
                            ? Icons.expand_less
                            : Icons.expand_more),
                      ],
                    ),
                  ),
                  if (_isFormulaExpanded) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Match Score (0-10):\n'
                      '• Rating: 30% × (rating/10)\n'
                      '• Goals: min(2.0, goals × 1.0)\n'
                      '• Assists: min(1.4, assists × 0.7)\n'
                      '• Passes: min(1.2, passes/60 × 1.2)\n'
                      '• Tackles: min(0.9, tackles/10 × 0.9)\n'
                      '• Minutes: min(0.8, minutesPlayed/90 × 0.8)\n'
                      '• Result: Win=0.7, Draw=0.35, Loss=0\n\n'
                      'Training Score (0-10):\n'
                      '• Intensity: (intensity/5) × 4.0\n'
                      '• Duration: min(3.0, duration/60 × 3.0)\n'
                      '• Distance: min(1.5, distance/8.0 × 1.5)\n'
                      '• Calories: min(1.5, calories/800 × 1.5)',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.6),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _isHomeMatch(Match match, AppProvider provider) {
    return match.homeTeam.toLowerCase() == provider.profileTeam.toLowerCase();
  }

  double _calculateAverageForm(
      List<Match> matches, List<TrainingSession> sessions) {
    final entries = <double>[];

    for (final match in matches) {
      entries.add(_calculateMatchScore(match));
    }

    for (final session in sessions) {
      entries.add(_calculateTrainingScore(session));
    }

    if (entries.isEmpty) return 0;
    return entries.fold<double>(0, (a, b) => a + b) / entries.length;
  }

  List<double> _calculateRollingAverage(List<_FormEntry> entries) {
    if (entries.length < 2) {
      return List.filled(
          entries.length, entries.isNotEmpty ? entries[0].score : 0);
    }

    final result = <double>[];
    const window = 7;

    for (int i = 0; i < entries.length; i++) {
      final start = math.max(0, i - window + 1);
      final windowEntries = entries.skip(start).take(i - start + 1);
      final avg = windowEntries.fold<double>(0, (a, b) => a + b.score) /
          windowEntries.length;
      result.add(avg);
    }
    return result;
  }

  double _calculateMatchScore(Match match) {
    double score = 0;

    // Rating (up to 3.0)
    score += (match.rating.clamp(0, 10) / 10) * 3.0;

    // Goals (up to 2.0)
    score += math.min(2.0, match.goals * 1.0);

    // Assists (up to 1.4)
    score += math.min(1.4, match.assists * 0.7);

    // Passes (up to 1.2)
    score += math.min(1.2, (match.passes / 60) * 1.2);

    // Tackles (up to 0.9)
    score += math.min(0.9, (match.tackles / 10) * 0.9);

    // Minutes played (up to 0.8)
    score += math.min(0.8, (match.minutesPlayed / 90) * 0.8);

    // Result bonus
    if (match.result == 'Win') {
      score += 0.7;
    } else if (match.result == 'Draw') {
      score += 0.35;
    }

    return score.clamp(0, 10);
  }

  double _calculateTrainingScore(TrainingSession session) {
    double score = 0;

    // Intensity (up to 4.0)
    score += (session.intensity.clamp(1, 5) / 5) * 4.0;

    // Duration (up to 3.0)
    score += math.min(3.0, (session.duration / 60) * 3.0);

    // Distance (up to 1.5)
    score += math.min(1.5, ((session.distance ?? 0) / 8.0) * 1.5);

    // Calories burned (up to 1.5)
    score += math.min(1.5, ((session.caloriesBurned ?? 0) / 800) * 1.5);

    return score.clamp(0, 10);
  }

  Widget _buildFormChart(List<Match> matches, List<TrainingSession> sessions) {
    final entries = <_FormEntry>[];

    for (final match in matches) {
      entries.add(_FormEntry(
        score: _calculateMatchScore(match),
        isMatch: true,
        date: match.date,
      ));
    }

    for (final session in sessions) {
      entries.add(_FormEntry(
        score: _calculateTrainingScore(session),
        isMatch: false,
        date: session.date,
      ));
    }

    entries.sort((a, b) => a.date.compareTo(b.date));

    // Take last 8 entries
    if (entries.length > 8) {
      entries.removeRange(0, entries.length - 8);
    }

    if (entries.isEmpty) {
      return Center(
        child: Text('No data available',
            style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
      );
    }

    final spots = <fl_chart.FlSpot>[];
    final trendSpots = <fl_chart.FlSpot>[];
    final labels = <String>[];

    // Calculate 7-day rolling average for trend line
    final rollingAverage = _calculateRollingAverage(entries);

    for (int i = 0; i < entries.length; i++) {
      spots.add(fl_chart.FlSpot(i.toDouble(), entries[i].score));
      labels.add(entries[i].isMatch ? 'M' : 'T');
      if (rollingAverage.length > i) {
        trendSpots.add(fl_chart.FlSpot(i.toDouble(), rollingAverage[i]));
      }
    }

    final peakScore = entries.map((e) => e.score).reduce(math.max);
    final trendPeak =
        rollingAverage.isNotEmpty ? rollingAverage.reduce(math.max) : peakScore;

    return fl_chart.LineChart(
      fl_chart.LineChartData(
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: 0,
        maxY: math.max(
            10.0, (math.max(peakScore, trendPeak).ceil() + 1).toDouble()),
        lineBarsData: [
          fl_chart.LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: fl_chart.FlDotData(show: true),
            belowBarData: fl_chart.BarAreaData(
              show: true,
              color: AppColors.primary.withAlpha(30),
            ),
          ),
          if (trendSpots.length >= 2)
            fl_chart.LineChartBarData(
              spots: trendSpots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 2,
              dashArray: [5, 3],
              dotData: fl_chart.FlDotData(show: false),
            ),
        ],
        titlesData: fl_chart.FlTitlesData(
          leftTitles: fl_chart.AxisTitles(
            sideTitles: fl_chart.SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(fontSize: 12),
                  );
                }),
          ),
          bottomTitles: fl_chart.AxisTitles(
            sideTitles: fl_chart.SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(labels[index],
                      style: GoogleFonts.inter(fontSize: 12));
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(showTitles: false)),
          rightTitles: fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(showTitles: false)),
        ),
        gridData: fl_chart.FlGridData(show: false),
      ),
    );
  }

  Widget _buildTrainingEffectiveness(
      List<Match> matches, List<TrainingSession> sessions) {
    if (matches.isEmpty || sessions.isEmpty) {
      return Text('Add training sessions and matches to see insights',
          style: GoogleFonts.inter(
              fontSize: 12, color: AppColors.onSurfaceVariant));
    }

    final Map<String, List<double>> trainingToMatchRatings = {};
    final consideredMatches = <double>[];

    for (final match in matches) {
      DateTime matchDate;
      try {
        matchDate = DateTime.parse(match.date);
      } catch (_) {
        continue;
      }

      final windowStart = matchDate.subtract(const Duration(hours: 48));
      final sessionsInWindow = sessions.where((s) {
        if (s.trainingType == null || s.trainingType!.trim().isEmpty) {
          return false;
        }
        final d = DateTime.tryParse(s.date);
        if (d == null) return false;
        return !d.isBefore(windowStart) && d.isBefore(matchDate);
      }).toList();

      if (sessionsInWindow.isEmpty) continue;

      consideredMatches.add(match.rating.toDouble());

      final typesUsed = sessionsInWindow
          .map((s) => s.trainingType!.trim())
          .where((t) => t.isNotEmpty)
          .toSet();

      for (final type in typesUsed) {
        trainingToMatchRatings
            .putIfAbsent(type, () => [])
            .add(match.rating.toDouble());
      }
    }

    if (trainingToMatchRatings.isEmpty) {
      return Text('No training sessions found in the 48h before matches',
          style: GoogleFonts.inter(
              fontSize: 12, color: AppColors.onSurfaceVariant));
    }

    final baseline = consideredMatches.isEmpty
        ? 0.0
        : consideredMatches.reduce((a, b) => a + b) / consideredMatches.length;

    final effectiveness = <MapEntry<String, double>>[];
    for (final entry in trainingToMatchRatings.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      effectiveness.add(MapEntry(entry.key, avg));
    }

    effectiveness.sort((a, b) => b.value.compareTo(a.value));

    final best = effectiveness.first;
    final bestDelta = best.value - baseline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Best pre-match type: ${best.key} (${bestDelta >= 0 ? '+' : ''}${bestDelta.toStringAsFixed(1)} rating vs baseline)',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...effectiveness.take(3).map((e) {
          final isPositive = e.value >= baseline;
          final delta = e.value - baseline;
          final samples = trainingToMatchRatings[e.key]?.length ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${e.key} ($samples matches)',
                      style: GoogleFonts.inter(fontSize: 14)),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isPositive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                        '${e.value.toStringAsFixed(1)} (${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)})',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value,
              style: GoogleFonts.lexend(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildWinRateBox(String label, String rate) {
    return Column(
      children: [
        Text(rate,
            style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _FormEntry {
  final double score;
  final bool isMatch;
  final String date;

  _FormEntry({
    required this.score,
    required this.isMatch,
    required this.date,
  });
}
