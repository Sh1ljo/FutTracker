import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/training_log_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/form_guide_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..loadAll(),
      child: const FootballTrackerApp(),
    ),
  );
}

class FootballTrackerApp extends StatelessWidget {
  const FootballTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutTracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onSwitchTab: (i) => setState(() => _currentIndex = i)),
      const TrainingLogScreen(),
      const MatchesScreen(),
      const StatisticsScreen(),
      const FormGuideScreen(),
      const ProfileScreen(),
    ];
  }

  static const _navItems = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_note_outlined),
      selectedIcon: Icon(Icons.event_note),
      label: 'Logs',
    ),
    NavigationDestination(
      icon: Icon(Icons.sports_soccer_outlined),
      selectedIcon: Icon(Icons.sports_soccer),
      label: 'Matches',
    ),
    NavigationDestination(
      icon: Icon(Icons.leaderboard_outlined),
      selectedIcon: Icon(Icons.leaderboard),
      label: 'Stats',
    ),
    NavigationDestination(
      icon: Icon(Icons.trending_up_outlined),
      selectedIcon: Icon(Icons.trending_up),
      label: 'Form',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;

    return Scaffold(
      body: isLoading
          ? _buildSplash()
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSplash() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.sports_soccer, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text('FutTracker',
                style: GoogleFonts.lexend(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Loading your data...',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          height: 60,
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(size: 20),
          ),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.secondaryContainer,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: _navItems,
          ),
        ),
      ),
    );
  }
}
