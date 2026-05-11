import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stats = provider.dashboardStats;
    final trainings = stats['trainings'] as int? ?? 0;
    final games = stats['games'] as int? ?? 0;
    final goals = stats['goals'] as int? ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: Text(
                  provider.profileName.isNotEmpty
                      ? provider.profileName[0].toUpperCase()
                      : 'A',
                  style: GoogleFonts.lexend(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            title: Text('Profile',
                style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Edit Profile',
                onPressed: () => _openEditProfile(context, provider),
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
                _buildProfileHeader(context, provider, trainings, games, goals),
                const SizedBox(height: 20),
                _buildWeeklyGoal(provider),
                const SizedBox(height: 20),
                _buildSettings(context, provider),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfile(BuildContext context, AppProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(provider: provider)),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppProvider provider,
      int trainings, int games, int goals) {
    final skills = provider.profileSkills
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Row(children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(30),
              border: Border.all(color: Colors.white.withAlpha(80), width: 2),
            ),
            child: Center(
              child: Text(
                provider.profileName.isNotEmpty
                    ? provider.profileName[0].toUpperCase()
                    : 'A',
                style: GoogleFonts.lexend(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(provider.profileName,
                  style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(provider.profilePosition,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.white.withAlpha(200))),
              if (provider.profileTeam.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.shield_outlined,
                      size: 13, color: Colors.white.withAlpha(180)),
                  const SizedBox(width: 4),
                  Text(provider.profileTeam,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white.withAlpha(180))),
                  if (provider.profileJerseyNumber.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text('#${provider.profileJerseyNumber}',
                        style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(200))),
                  ],
                ]),
              ],
              if (provider.profileAge.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('Age ${provider.profileAge}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white.withAlpha(160))),
              ],
            ]),
          ),
          GestureDetector(
            onTap: () => _openEditProfile(context, provider),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 18, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // Skills
        if (skills.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withAlpha(60)),
                        ),
                        child: Text(s,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Stats row
        Row(children: [
          _statBox('$trainings', 'Sessions'),
          _vertDivider(),
          _statBox('$games', 'Matches'),
          _vertDivider(),
          _statBox('$goals', 'Goals'),
        ]),
      ]),
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white.withAlpha(180))),
      ]),
    );
  }

  Widget _vertDivider() {
    return Container(width: 1, height: 40, color: Colors.white.withAlpha(40));
  }

  Widget _buildWeeklyGoal(AppProvider provider) {
    final goal = provider.profileWeeklyGoal;
    final sessions = provider.dashboardStats['trainings'] as int? ?? 0;
    // Sessions this week (rough calc from total; a real app would filter by week)
    final weeklyProgress = (sessions % 7).clamp(0, goal);
    final ratio = goal > 0 ? (weeklyProgress / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Weekly Training Goal',
              style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text('$weeklyProgress / $goal sessions',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          ratio >= 1.0
              ? '🎉 Goal achieved this week!'
              : '${goal - weeklyProgress} sessions to reach your weekly goal',
          style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
      ]),
    );
  }

  Widget _buildSettings(BuildContext context, AppProvider provider) {
    final items = [
      {
        'icon': Icons.person_outline,
        'title': 'Edit Profile',
        'sub': 'Update name, position & skills',
        'action': () => _openEditProfile(context, provider),
      },
      {
        'icon': Icons.tune_outlined,
        'title': 'Preferences',
        'sub': 'Units, display & training defaults',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreferencesScreen()),
            ),
      },
      {
        'icon': Icons.notifications_active_outlined,
        'title': 'Notifications',
        'sub': 'Manage alerts and reminders',
        'action': () {},
      },
      {
        'icon': Icons.info_outline,
        'title': 'About',
        'sub': 'FutTracker v1.0.0',
        'action': () {},
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('Settings',
              style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground)),
        ),
        const Divider(height: 1, color: AppColors.outlineVariant),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(children: [
            InkWell(
              onTap: item['action'] as VoidCallback,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: AppColors.onSecondaryContainer, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onBackground)),
                          Text(item['sub'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant)),
                        ]),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.outlineVariant),
                ]),
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                  height: 1, color: AppColors.outlineVariant, indent: 70),
          ]);
        }),
      ]),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
        label: Text('Logout',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Profile Screen
// ─────────────────────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  final AppProvider provider;
  const EditProfileScreen({super.key, required this.provider});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _positionCtrl;
  late final TextEditingController _teamCtrl;
  late final TextEditingController _jerseyCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _weeklyGoalCtrl;
  final Set<String> _skills = {};
  bool _saving = false;

  static const _allSkills = [
    'Dribbling',
    'Passing',
    'Shooting',
    'Speed',
    'Stamina',
    'Defending',
    'Heading',
    'Leadership',
    'Vision',
    'Agility',
    'Strength',
    'Positioning',
    'Ball Control',
    'Finishing',
    'Free Kicks',
    'Pressing',
  ];

  static const _positions = [
    'Goalkeeper',
    'Centre Back',
    'Left Back',
    'Right Back',
    'Defensive Mid',
    'Central Mid',
    'Attacking Mid',
    'Left Winger',
    'Right Winger',
    'Striker',
    'Second Striker',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _nameCtrl = TextEditingController(text: p.profileName);
    _positionCtrl = TextEditingController(text: p.profilePosition);
    _teamCtrl = TextEditingController(text: p.profileTeam);
    _jerseyCtrl = TextEditingController(text: p.profileJerseyNumber);
    _ageCtrl = TextEditingController(text: p.profileAge);
    _weeklyGoalCtrl = TextEditingController(text: '${p.profileWeeklyGoal}');
    _skills.addAll(p.profileSkills
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _positionCtrl.dispose();
    _teamCtrl.dispose();
    _jerseyCtrl.dispose();
    _ageCtrl.dispose();
    _weeklyGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.provider.saveProfile({
      'name': _nameCtrl.text.trim(),
      'position': _positionCtrl.text.trim(),
      'team': _teamCtrl.text.trim(),
      'jersey_number': _jerseyCtrl.text.trim(),
      'age': _ageCtrl.text.trim(),
      'weekly_goal': _weeklyGoalCtrl.text.trim().isEmpty
          ? '5'
          : _weeklyGoalCtrl.text.trim(),
      'skills': _skills.join(','),
    });
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryContainer))
                  : Text('Save',
                      style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContainer)),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ─── Avatar ──────────────────────────────────────────────
            Center(
              child: Stack(children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _nameCtrl,
                      builder: (_, v, __) => Text(
                        v.text.isNotEmpty ? v.text[0].toUpperCase() : 'A',
                        style: GoogleFonts.lexend(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ─── Personal Info ────────────────────────────────────────
            _sectionCard([
              _sectionHeader('Personal Info', Icons.person_outline),
              const SizedBox(height: 16),
              _buildField('Full Name', _nameCtrl,
                  hint: 'e.g. Alex Rivers',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Name is required'
                      : null),
              const SizedBox(height: 14),
              _buildField('Age', _ageCtrl,
                  hint: 'e.g. 22',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _buildField('Team / Club', _teamCtrl,
                  hint: 'e.g. Eagles FC', icon: Icons.shield_outlined),
              const SizedBox(height: 14),
              _buildField('Jersey Number', _jerseyCtrl,
                  hint: 'e.g. 10',
                  icon: Icons.tag_outlined,
                  keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 16),

            // ─── Position ─────────────────────────────────────────────
            _sectionCard([
              _sectionHeader('Playing Position', Icons.sports_soccer_outlined),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _positions.map((pos) {
                  final selected = _positionCtrl.text == pos;
                  return GestureDetector(
                    onTap: () => setState(() => _positionCtrl.text = pos),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: selected
                                ? AppColors.primaryContainer
                                : AppColors.outlineVariant),
                      ),
                      child: Text(pos,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : AppColors.onBackground)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              _buildField('Or type custom position', _positionCtrl,
                  hint: 'e.g. Professional Forward', icon: Icons.edit_outlined),
            ]),
            const SizedBox(height: 16),

            // ─── Skills ───────────────────────────────────────────────
            _sectionCard([
              _sectionHeader('Key Strengths', Icons.star_outline),
              const SizedBox(height: 4),
              Text('Pick up to 6 skills that define your game',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allSkills.map((skill) {
                  final selected = _skills.contains(skill);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _skills.remove(skill);
                      } else if (_skills.length < 6) {
                        _skills.add(skill);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.secondaryContainer
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.outlineVariant),
                      ),
                      child: Text(skill,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant)),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // ─── Training Goal ────────────────────────────────────────
            _sectionCard([
              _sectionHeader('Weekly Training Goal', Icons.flag_outlined),
              const SizedBox(height: 4),
              Text('How many sessions do you aim for per week?',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [2, 3, 4, 5, 6, 7].map((n) {
                      final selected = _weeklyGoalCtrl.text == '$n';
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _weeklyGoalCtrl.text = '$n'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: selected
                                    ? AppColors.primaryContainer
                                    : AppColors.outlineVariant),
                          ),
                          child: Center(
                            child: Text('$n',
                                style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.onSurfaceVariant)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 28),

            // ─── Save Button ──────────────────────────────────────────
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
                    : const Icon(Icons.check_circle_outline,
                        color: Colors.white),
                label: Text('Save Profile',
                    style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ]),
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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground)),
    ]);
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant, fontSize: 13),
          prefixIcon: icon != null
              ? Icon(icon, size: 19, color: AppColors.onSurfaceVariant)
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          constraints: const BoxConstraints(maxHeight: 56),
          isDense: true,
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preferences Screen
// ─────────────────────────────────────────────────────────────────────────────

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Units
  String _distanceUnit = 'km'; // 'km' | 'mi'
  String _weightUnit = 'kg'; // 'kg' | 'lbs'
  String _firstDayOfWeek = 'Monday'; // 'Monday' | 'Sunday'

  // Display toggles
  bool _showDistance = true;
  bool _showCalories = true;
  bool _compactCards = false;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = context.read<AppProvider>();
    setState(() {
      _distanceUnit = p.profile['pref_distance_unit'] ?? 'km';
      _weightUnit = p.profile['pref_weight_unit'] ?? 'kg';
      _firstDayOfWeek = p.profile['pref_first_day'] ?? 'Monday';
      _showDistance = (p.profile['pref_show_distance'] ?? 'true') == 'true';
      _showCalories = (p.profile['pref_show_calories'] ?? 'true') == 'true';
      _compactCards = (p.profile['pref_compact_cards'] ?? 'false') == 'true';
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AppProvider>().saveProfile({
      'pref_distance_unit': _distanceUnit,
      'pref_weight_unit': _weightUnit,
      'pref_first_day': _firstDayOfWeek,
      'pref_show_distance': '$_showDistance',
      'pref_show_calories': '$_showCalories',
      'pref_compact_cards': '$_compactCards',
    });
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preferences saved!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Preferences',
            style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryContainer))
                  : Text('Save',
                      style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContainer)),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryContainer))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Units ────────────────────────────────────────────────
                    _sectionCard([
                      _sectionHeader('Units', Icons.straighten_outlined),
                      const SizedBox(height: 20),
                      _labelText('Distance Unit'),
                      const SizedBox(height: 8),
                      _segmentedPicker(
                        options: const ['km', 'mi'],
                        selected: _distanceUnit,
                        onSelect: (v) => setState(() => _distanceUnit = v),
                        labels: const ['Kilometres (km)', 'Miles (mi)'],
                      ),
                      const SizedBox(height: 20),
                      _labelText('Weight Unit'),
                      const SizedBox(height: 8),
                      _segmentedPicker(
                        options: const ['kg', 'lbs'],
                        selected: _weightUnit,
                        onSelect: (v) => setState(() => _weightUnit = v),
                        labels: const ['Kilograms (kg)', 'Pounds (lbs)'],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ─── Calendar ─────────────────────────────────────────────
                    _sectionCard([
                      _sectionHeader('Calendar', Icons.calendar_month_outlined),
                      const SizedBox(height: 20),
                      _labelText('First Day of Week'),
                      const SizedBox(height: 8),
                      _segmentedPicker(
                        options: const ['Monday', 'Sunday'],
                        selected: _firstDayOfWeek,
                        onSelect: (v) => setState(() => _firstDayOfWeek = v),
                        labels: const ['Monday', 'Sunday'],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ─── Display ──────────────────────────────────────────────
                    _sectionCard([
                      _sectionHeader(
                          'Training Log Display', Icons.view_list_outlined),
                      const SizedBox(height: 8),
                      Text('Control what\'s shown on training cards',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      _buildToggleTile(
                        icon: Icons.straighten_outlined,
                        title: 'Show Distance',
                        subtitle: 'Display km/mi badge on session cards',
                        value: _showDistance,
                        onChanged: (v) => setState(() => _showDistance = v),
                      ),
                      const Divider(height: 1, color: AppColors.outlineVariant),
                      _buildToggleTile(
                        icon: Icons.local_fire_department_outlined,
                        title: 'Show Calories',
                        subtitle: 'Display calorie badge on session cards',
                        value: _showCalories,
                        onChanged: (v) => setState(() => _showCalories = v),
                      ),
                      const Divider(height: 1, color: AppColors.outlineVariant),
                      _buildToggleTile(
                        icon: Icons.view_agenda_outlined,
                        title: 'Compact Cards',
                        subtitle: 'Use smaller cards in the training log',
                        value: _compactCards,
                        onChanged: (v) => setState(() => _compactCards = v),
                      ),
                    ]),
                    const SizedBox(height: 28),

                    // ─── Save ─────────────────────────────────────────────────
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
                            : const Icon(Icons.check_circle_outline,
                                color: Colors.white),
                        label: Text('Save Preferences',
                            style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ]),
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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground)),
    ]);
  }

  Widget _labelText(String label) {
    return Text(label,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant));
  }

  Widget _segmentedPicker({
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
    required List<String> labels,
  }) {
    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = selected == options[i];
        final isFirst = i == 0;
        final isLast = i == options.length - 1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(options[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.horizontal(
                  left: isFirst ? const Radius.circular(10) : Radius.zero,
                  right: isLast ? const Radius.circular(10) : Radius.zero,
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.outlineVariant,
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : AppColors.onSurfaceVariant),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground)),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ]),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryContainer,
          activeTrackColor: AppColors.secondaryContainer,
        ),
      ]),
    );
  }
}
