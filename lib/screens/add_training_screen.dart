import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/training_session.dart';

class AddTrainingScreen extends StatefulWidget {
  final TrainingSession? existing;
  const AddTrainingScreen({super.key, this.existing});

  @override
  State<AddTrainingScreen> createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final _durationCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  late int _intensity;
  String? _trainingType;
  final Set<String> _focusAreas = {};
  bool _saved = false;
  bool _saving = false;

  static const _trainingTypes = [
    ('Tactical', Icons.psychology_outlined),
    ('Fitness', Icons.directions_run_outlined),
    ('Technical', Icons.sports_soccer_outlined),
    ('Match Prep', Icons.event_outlined),
    ('Recovery', Icons.self_improvement_outlined),
    ('Gym', Icons.fitness_center_outlined),
  ];

  static const _allFocusAreas = [
    'Dribbling', 'Passing', 'Shooting', 'Pressing',
    'Positioning', 'Stamina', 'Speed', 'Strength',
    'Core', 'Agility', 'Team Shape', 'Explosiveness',
    'Mental Reset', 'Ball Control', 'Headers', 'Defending',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _selectedDate = e != null ? DateTime.parse(e.date) : DateTime.now();
    _intensity = e?.intensity ?? 3;
    _trainingType = e?.trainingType;
    _durationCtrl.text = e != null ? '${e.duration}' : '';
    _distanceCtrl.text = e?.distance?.toStringAsFixed(1) ?? '';
    _locationCtrl.text = e?.location ?? '';
    _notesCtrl.text = e?.notes ?? '';
    _caloriesCtrl.text = e?.caloriesBurned?.toString() ?? '';
    _heartRateCtrl.text = e?.heartRateAvg?.toString() ?? '';
    if (e != null) _focusAreas.addAll(e.focusAreaList);
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    _caloriesCtrl.dispose();
    _heartRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final session = TrainingSession(
      id: widget.existing?.id,
      date: _selectedDate.toIso8601String().split('T')[0],
      duration: int.parse(_durationCtrl.text.trim()),
      intensity: _intensity,
      distance: _distanceCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_distanceCtrl.text.trim()),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now().toIso8601String(),
      trainingType: _trainingType,
      caloriesBurned: _caloriesCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_caloriesCtrl.text.trim()),
      heartRateAvg: _heartRateCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_heartRateCtrl.text.trim()),
      focusAreas: _focusAreas.isNotEmpty ? _focusAreas.join(',') : null,
    );
    if (widget.existing != null) {
      await context.read<AppProvider>().updateSession(session);
    } else {
      await context.read<AppProvider>().addSession(session);
    }
    setState(() { _saved = true; _saving = false; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryContainer,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
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
        title: Text(isEdit ? 'Edit Session' : 'Log Training',
            style: GoogleFonts.lexend(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_saved) _buildSuccessBanner(),
              if (_saved) const SizedBox(height: 16),

              // ─── Session Overview ────────────────────────────────
              _sectionCard([
                _sectionHeader('Session Overview', Icons.event_note_outlined),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDurationField()),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _buildDistanceField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLocationField()),
                ]),
              ]),
              const SizedBox(height: 16),

              // ─── Training Type ───────────────────────────────────
              _sectionCard([
                _sectionHeader('Training Type', Icons.category_outlined),
                const SizedBox(height: 12),
                _buildTrainingTypeGrid(),
              ]),
              const SizedBox(height: 16),

              // ─── Intensity ───────────────────────────────────────
              _sectionCard([
                _sectionHeader('Intensity Level', Icons.bolt_outlined),
                const SizedBox(height: 12),
                _buildIntensitySelector(),
              ]),
              const SizedBox(height: 16),

              // ─── Biometrics ──────────────────────────────────────
              _sectionCard([
                _sectionHeader('Performance Metrics', Icons.monitor_heart_outlined),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _buildCaloriesField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHeartRateField()),
                ]),
              ]),
              const SizedBox(height: 16),

              // ─── Focus Areas ─────────────────────────────────────
              _sectionCard([
                _sectionHeader('Focus Areas', Icons.track_changes_outlined),
                const SizedBox(height: 4),
                Text('Select all that apply',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                _buildFocusAreaChips(),
              ]),
              const SizedBox(height: 16),

              // ─── Notes ───────────────────────────────────────────
              _sectionCard([
                _sectionHeader('Session Notes', Icons.notes_outlined),
                const SizedBox(height: 12),
                _buildNotesField(),
              ]),
              const SizedBox(height: 24),

              // ─── Save Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(isEdit ? Icons.save : Icons.check_circle_outline, color: Colors.white),
                  label: Text(isEdit ? 'Update Session' : 'Save Training',
                      style: GoogleFonts.lexend(
                          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: GoogleFonts.lexend(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
    ]);
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(
              color: AppColors.primaryContainer, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Session Saved!',
                style: GoogleFonts.lexend(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
            Text('Your training log has been updated.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDateField() {
    return _fieldLabel('Date', GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onBackground),
          ),
        ]),
      ),
    ));
  }

  Widget _buildDurationField() {
    return _fieldLabel('Duration (mins)', TextFormField(
      controller: _durationCtrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'e.g. 45',
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.onSurfaceVariant, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    ));
  }

  Widget _buildDistanceField() {
    return _fieldLabel('Distance (km)', TextFormField(
      controller: _distanceCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'e.g. 5.5',
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        prefixIcon: const Icon(Icons.directions_run_outlined, color: AppColors.onSurfaceVariant, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));
  }

  Widget _buildLocationField() {
    return _fieldLabel('Location', TextFormField(
      controller: _locationCtrl,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Training Ground A',
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));
  }

  Widget _buildCaloriesField() {
    return _fieldLabel('Calories Burned', TextFormField(
      controller: _caloriesCtrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'e.g. 650',
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        prefixIcon: const Icon(Icons.local_fire_department_outlined, color: AppColors.onSurfaceVariant, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));
  }

  Widget _buildHeartRateField() {
    return _fieldLabel('Avg Heart Rate (bpm)', TextFormField(
      controller: _heartRateCtrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'e.g. 148',
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        prefixIcon: const Icon(Icons.monitor_heart_outlined, color: AppColors.onSurfaceVariant, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ));
  }

  Widget _fieldLabel(String label, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 6),
      child,
    ]);
  }

  Widget _buildTrainingTypeGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _trainingTypes.map((t) {
        final selected = _trainingType == t.$1;
        return GestureDetector(
          onTap: () => setState(() => _trainingType = selected ? null : t.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.primaryContainer : AppColors.outlineVariant,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(t.$2, size: 16,
                  color: selected ? Colors.white : AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(t.$1,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.onBackground)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntensitySelector() {
    final labels = ['1', '2', '3', '4', '5'];
    final intensityNames = ['Recovery', 'Low', 'Medium', 'High', 'All Out'];
    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: labels.map((label) {
            final val = int.parse(label);
            final selected = _intensity == val;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _intensity = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.onSurfaceVariant)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(intensityNames[_intensity - 1],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ),
    ]);
  }

  Widget _buildFocusAreaChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allFocusAreas.map((area) {
        final selected = _focusAreas.contains(area);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) { _focusAreas.remove(area); }
            else { _focusAreas.add(area); }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outlineVariant,
              ),
            ),
            child: Text(area,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.onSurfaceVariant)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesCtrl,
      maxLines: 4,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'How did it go? What did you work on? How do you feel?',
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }
}
