import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/training_session.dart';
import 'add_training_screen.dart';

class TrainingLogScreen extends StatelessWidget {
  const TrainingLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<AppProvider>().sessions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('Training Log',
                style: GoogleFonts.lexend(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
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
                _buildLogButton(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Session History',
                        style: GoogleFonts.lexend(
                            fontSize: 20, fontWeight: FontWeight.w600,
                            color: AppColors.onBackground)),
                    if (sessions.isNotEmpty)
                      Text('${sessions.length} sessions',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 12),
                if (sessions.isEmpty)
                  _buildEmpty(context)
                else
                  ...sessions.map((s) => _SessionCard(session: s)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddTrainingScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Session',
            style: GoogleFonts.lexend(
                fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.event_note_outlined, size: 32, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text('No sessions yet',
            style: GoogleFonts.lexend(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        Text('Tap "New Session" to log your first training.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
      ]),
    );
  }
}

class _SessionCard extends StatefulWidget {
  final TrainingSession session;
  const _SessionCard({required this.session});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) { _controller.forward(); } else { _controller.reverse(); }
  }

  // Intensity color mapping
  static const _intensityColors = [
    Color(0xFFE0F2FE), // 1 Recovery - blue tint
    Color(0xFFDCFCE7), // 2 Low - green
    Color(0xFFFEF9C3), // 3 Medium - yellow
    Color(0xFFFEF3C7), // 4 High - amber
    Color(0xFFFEE2E2), // 5 All Out - red
  ];
  static const _intensityTextColors = [
    Color(0xFF0369A1),
    Color(0xFF166534),
    Color(0xFF854D0E),
    Color(0xFF92400E),
    Color(0xFFB91C1C),
  ];

  static const _typeIconMap = {
    'Tactical': Icons.psychology_outlined,
    'Fitness': Icons.directions_run_outlined,
    'Technical': Icons.sports_soccer_outlined,
    'Match Prep': Icons.event_outlined,
    'Recovery': Icons.self_improvement_outlined,
    'Gym': Icons.fitness_center_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final colorIdx = (s.intensity - 1).clamp(0, 4);
    final typeIcon = _typeIconMap[s.trainingType] ?? Icons.fitness_center_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggle,
        onLongPress: () => _showOptions(context, s),
        child: Column(children: [
          // ─── Summary Row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Type icon
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        s.trainingType ?? (s.location?.isNotEmpty == true ? s.location! : 'Training Session'),
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.onBackground),
                      ),
                    ),
                    // Intensity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _intensityColors[colorIdx],
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(s.intensityLabel,
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: _intensityTextColors[colorIdx])),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitle(s),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.outlineVariant, size: 22),
              ),
            ]),
          ),

          // ─── Metrics Row (always visible if data exists) ──────
          if (s.caloriesBurned != null || s.heartRateAvg != null || s.distance != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
              child: Row(children: [
                if (s.caloriesBurned != null) ...[
                  _metricBadge(Icons.local_fire_department_outlined,
                      '${s.caloriesBurned} kcal', const Color(0xFFFED7AA), const Color(0xFF9A3412)),
                  const SizedBox(width: 8),
                ],
                if (s.heartRateAvg != null) ...[
                  _metricBadge(Icons.favorite_outline,
                      '${s.heartRateAvg} bpm', const Color(0xFFFECACA), const Color(0xFF991B1B)),
                  const SizedBox(width: 8),
                ],
                if (s.distance != null)
                  _metricBadge(Icons.straighten_outlined,
                      '${s.distance!.toStringAsFixed(1)} km', const Color(0xFFBFDBFE), const Color(0xFF1E40AF)),
              ]),
            ),

          // ─── Expanded Details ─────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(children: [
              const Divider(height: 1, color: AppColors.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Focus areas
                  if (s.focusAreaList.isNotEmpty) ...[
                    Text('Focus Areas',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: s.focusAreaList.map((a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(a,
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Location
                  if (s.location != null && s.location!.isNotEmpty) ...[
                    _detailRow(Icons.location_on_outlined, 'Location', s.location!),
                    const SizedBox(height: 8),
                  ],

                  // Notes
                  if (s.notes != null && s.notes!.isNotEmpty) ...[
                    _detailRow(Icons.notes_outlined, 'Notes', s.notes!),
                    const SizedBox(height: 8),
                  ],

                  // Date
                  _detailRow(Icons.calendar_today_outlined, 'Date', s.date),
                  const SizedBox(height: 14),

                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTrainingScreen(existing: s),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text('Edit', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(context, s),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text('Delete', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _metricBadge(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppColors.onSurfaceVariant),
      const SizedBox(width: 6),
      Text('$label: ', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      Expanded(
        child: Text(value, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onBackground)),
      ),
    ]);
  }

  String _buildSubtitle(TrainingSession s) {
    final parts = <String>[s.date, '${s.duration} mins'];
    if (s.location != null && s.location!.isNotEmpty && s.trainingType != null) {
      parts.add(s.location!);
    }
    return parts.join('  •  ');
  }

  void _showOptions(BuildContext context, TrainingSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: Text('Edit Session', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddTrainingScreen(existing: session)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('Delete Session',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, session);
            },
          ),
        ]),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TrainingSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Session', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
        content: Text('Remove this training session from your log?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().deleteSession(session.id!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
