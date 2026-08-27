import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/match.dart';

class AddMatchScreen extends StatefulWidget {
  final Match? existing;
  const AddMatchScreen({super.key, this.existing});
  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late final TextEditingController _opponentCtrl;
  late final TextEditingController _homeTeamCtrl;
  late final TextEditingController _homeScoreCtrl;
  late final TextEditingController _awayScoreCtrl;
  late final TextEditingController _goalsCtrl;
  late final TextEditingController _assistsCtrl;
  late final TextEditingController _passesCtrl;
  late final TextEditingController _tacklesCtrl;
  late final TextEditingController _minutesCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _notesCtrl;
  late String _matchType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _selectedDate = e != null ? DateTime.parse(e.date) : DateTime.now();
    _opponentCtrl = TextEditingController(text: e?.opponent ?? '');
    _homeTeamCtrl = TextEditingController(text: e?.homeTeam ?? 'Eagles FC');
    _homeScoreCtrl = TextEditingController(text: '${e?.homeScore ?? 0}');
    _awayScoreCtrl = TextEditingController(text: '${e?.awayScore ?? 0}');
    _goalsCtrl = TextEditingController(text: '${e?.goals ?? 0}');
    _assistsCtrl = TextEditingController(text: '${e?.assists ?? 0}');
    _passesCtrl = TextEditingController(text: '${e?.passes ?? 0}');
    _tacklesCtrl = TextEditingController(text: '${e?.tackles ?? 0}');
    _minutesCtrl = TextEditingController(text: '${e?.minutesPlayed ?? 90}');
    _ratingCtrl = TextEditingController(text: '${e?.rating ?? 5}');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _matchType = e?.matchType ?? 'normal';
  }

  @override
  void dispose() {
    for (final c in [
      _opponentCtrl,
      _homeTeamCtrl,
      _homeScoreCtrl,
      _awayScoreCtrl,
      _goalsCtrl,
      _assistsCtrl,
      _passesCtrl,
      _tacklesCtrl,
      _minutesCtrl,
      _ratingCtrl,
      _notesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final match = Match(
      id: widget.existing?.id,
      date: _selectedDate.toIso8601String().split('T')[0],
      opponent: _opponentCtrl.text.trim(),
      homeTeam: _homeTeamCtrl.text.trim(),
      homeScore: int.tryParse(_homeScoreCtrl.text) ?? 0,
      awayScore: int.tryParse(_awayScoreCtrl.text) ?? 0,
      goals: int.tryParse(_goalsCtrl.text) ?? 0,
      assists: int.tryParse(_assistsCtrl.text) ?? 0,
      passes: int.tryParse(_passesCtrl.text) ?? 0,
      tackles: int.tryParse(_tacklesCtrl.text) ?? 0,
      minutesPlayed: int.tryParse(_minutesCtrl.text) ?? 90,
      rating: int.tryParse(_ratingCtrl.text) ?? 5,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now().toIso8601String(),
      matchType: _matchType,
    );
    if (widget.existing != null) {
      await context.read<AppProvider>().updateMatch(match);
    } else {
      await context.read<AppProvider>().addMatch(match);
    }
    setState(() => _saving = false);
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

  Widget _buildMatchTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _matchType = 'normal'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _matchType == 'normal'
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield,
                        size: 18,
                        color: _matchType == 'normal'
                            ? Colors.white
                            : AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text('Normal Match',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _matchType == 'normal'
                                ? Colors.white
                                : AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _matchType = 'five_a_side'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _matchType == 'five_a_side'
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 18,
                        color: _matchType == 'five_a_side'
                            ? Colors.white
                            : AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text('5-a-Side',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _matchType == 'five_a_side'
                                ? Colors.white
                                : AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        title: Text(isEdit ? 'Edit Match' : 'Log Match',
            style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
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
              Text(isEdit ? 'Edit Match Details' : 'Match Details',
                  style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground)),
              const SizedBox(height: 4),
              Text(
                  isEdit
                      ? 'Update your game stats.'
                      : 'Record your game stats.',
                  style: GoogleFonts.inter(
                      fontSize: 15, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 24),
              _buildMatchTypeSelector(),
              const SizedBox(height: 24),
              _section('Game Info', [
                Row(children: [
                  Expanded(child: _field('Date', _buildDateTap())),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _labeled(
                          'Opponent',
                          _textField(_opponentCtrl, 'vs. Team',
                              required: true))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _labeled(
                          'Your Team', _textField(_homeTeamCtrl, 'Eagles FC'))),
                  const SizedBox(width: 12),
                  Expanded(child: _labeled('Score (H-A)', _scoreRow())),
                ]),
              ]),
              const SizedBox(height: 16),
              _section('My Performance', [
                Row(children: [
                  Expanded(child: _labeled('Goals', _numField(_goalsCtrl))),
                  const SizedBox(width: 12),
                  Expanded(child: _labeled('Assists', _numField(_assistsCtrl))),
                  const SizedBox(width: 12),
                  Expanded(child: _labeled('Passes', _numField(_passesCtrl))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _labeled('Tackles', _numField(_tacklesCtrl))),
                  const SizedBox(width: 12),
                  Expanded(child: _labeled('Minutes', _numField(_minutesCtrl))),
                  const Expanded(child: SizedBox()),
                ]),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickChip('60 min', () => _minutesCtrl.text = '60'),
                    _quickChip('75 min', () => _minutesCtrl.text = '75'),
                    _quickChip('90 min', () => _minutesCtrl.text = '90'),
                    _quickChip('Rating 6', () => _ratingCtrl.text = '6'),
                    _quickChip('Rating 7', () => _ratingCtrl.text = '7'),
                    _quickChip('Rating 8', () => _ratingCtrl.text = '8'),
                  ],
                ),
                const SizedBox(height: 12),
                _ratingSection(),
              ]),
              const SizedBox(height: 16),
              _section('Notes', [
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Scored the winner in the 89th...',
                    hintStyle:
                        GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Icon(isEdit ? Icons.save : Icons.check_circle_outline,
                          color: Colors.white),
                  label: Text(isEdit ? 'Update Match' : 'Finish Game',
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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

  Widget _section(String title, List<Widget> children) {
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
          Text(title,
              style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _labeled(String label, Widget child) => _field(label, child);

  Widget _buildDateTap() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today,
              size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.onBackground),
          ),
        ]),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint,
      {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }

  Widget _numField(TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 14),
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return null;
        final parsed = int.tryParse(value);
        if (parsed == null) return 'Invalid';

        if (identical(ctrl, _minutesCtrl) && (parsed < 0 || parsed > 130)) {
          return '0-130';
        }
        if (identical(ctrl, _ratingCtrl) && (parsed < 1 || parsed > 10)) {
          return '1-10';
        }
        if ((identical(ctrl, _homeScoreCtrl) ||
                identical(ctrl, _awayScoreCtrl) ||
                identical(ctrl, _goalsCtrl) ||
                identical(ctrl, _assistsCtrl) ||
                identical(ctrl, _tacklesCtrl)) &&
            (parsed < 0 || parsed > 25)) {
          return '0-25';
        }
        if (identical(ctrl, _passesCtrl) && (parsed < 0 || parsed > 200)) {
          return '0-200';
        }
        return null;
      },
    );
  }

  Widget _scoreRow() {
    return Row(children: [
      Expanded(child: _numField(_homeScoreCtrl)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('-',
            style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant)),
      ),
      Expanded(child: _numField(_awayScoreCtrl)),
    ]);
  }

  Widget _ratingSection() {
    final currentRating = int.tryParse(_ratingCtrl.text) ?? 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Match Rating',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('$currentRating/10',
                  style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: RoundSliderThumbShape(
                elevation: 4,
                enabledThumbRadius: 12,
                pressedElevation: 6,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.primaryContainer,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
            ),
            child: Slider(
              value: currentRating.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$currentRating',
              onChanged: (value) {
                setState(() => _ratingCtrl.text = value.toInt().toString());
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () => setState(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant)),
      ),
    );
  }
}
