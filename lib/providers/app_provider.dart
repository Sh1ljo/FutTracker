import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/training_session.dart';
import '../models/match.dart';

class AppProvider extends ChangeNotifier {
  List<TrainingSession> _sessions = [];
  List<Match> _matches = [];
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _careerStats = {};
  Map<String, String> _profile = {};
  bool _isLoading = false;
  int _trainingStreak = 0;

  List<TrainingSession> get sessions => _sessions;
  List<Match> get matches => _matches;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  Map<String, dynamic> get careerStats => _careerStats;
  int get trainingStreak => _trainingStreak;
  Map<String, String> get profile => _profile;
  bool get isLoading => _isLoading;

  void _calculateTrainingStreak() {
    if (_sessions.isEmpty) {
      _trainingStreak = 0;
      return;
    }
    final sessionDates = _sessions
        .map((s) => s.date)
        .toSet();
    int streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      if (sessionDates.contains(key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    _trainingStreak = streak;
  }

  // Profile convenience getters
  String get profileName => _profile['name'] ?? 'Alex Rivers';
  String get profilePosition => _profile['position'] ?? 'Professional Forward';
  String get profileSkills => _profile['skills'] ?? 'Dribbling,Stamina';
  int get profileWeeklyGoal => int.tryParse(_profile['weekly_goal'] ?? '5') ?? 5;
  String get profileTeam => _profile['team'] ?? '';
  String get profileJerseyNumber => _profile['jersey_number'] ?? '';
  String get profileAge => _profile['age'] ?? '';

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _loadSessions(),
      _loadMatches(),
      _loadDashboardStats(),
      _loadCareerStats(),
      _loadProfile(),
    ]);
    _calculateTrainingStreak();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSessions() async {
    _sessions = await DatabaseHelper.instance.getAllTrainingSessions();
  }

  Future<void> _loadMatches() async {
    _matches = await DatabaseHelper.instance.getAllMatches();
  }

  Future<void> _loadDashboardStats() async {
    _dashboardStats = await DatabaseHelper.instance.getDashboardStats();
  }

  Future<void> _loadCareerStats() async {
    _careerStats = await DatabaseHelper.instance.getCareerStats();
  }

  Future<void> _loadProfile() async {
    _profile = await DatabaseHelper.instance.getAllProfileValues();
    notifyListeners();
  }

  Future<void> addSession(TrainingSession session) async {
    await DatabaseHelper.instance.insertTrainingSession(session);
    await loadAll();
    _calculateTrainingStreak();
  }

  Future<void> updateSession(TrainingSession session) async {
    await DatabaseHelper.instance.updateTrainingSession(session);
    await loadAll();
    _calculateTrainingStreak();
  }

  Future<void> deleteSession(int id) async {
    await DatabaseHelper.instance.deleteTrainingSession(id);
    await loadAll();
    _calculateTrainingStreak();
  }

  Future<void> addMatch(Match match) async {
    await DatabaseHelper.instance.insertMatch(match);
    await loadAll();
  }

  Future<void> updateMatch(Match match) async {
    await DatabaseHelper.instance.updateMatch(match);
    await loadAll();
  }

  Future<void> deleteMatch(int id) async {
    await DatabaseHelper.instance.deleteMatch(id);
    await loadAll();
    _calculateTrainingStreak();
  }

  Future<void> saveProfile(Map<String, String> values) async {
    for (final entry in values.entries) {
      await DatabaseHelper.instance.setProfileValue(entry.key, entry.value);
    }
    await _loadProfile();
    notifyListeners();
  }
}
