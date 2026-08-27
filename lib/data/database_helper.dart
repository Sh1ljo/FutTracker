import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/training_session.dart';
import '../models/match.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('football_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE training_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        intensity INTEGER NOT NULL,
        distance REAL,
        location TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        training_type TEXT,
        calories_burned INTEGER,
        heart_rate_avg INTEGER,
        focus_areas TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE matches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        opponent TEXT NOT NULL,
        home_team TEXT NOT NULL,
        home_score INTEGER DEFAULT 0,
        away_score INTEGER DEFAULT 0,
        goals INTEGER DEFAULT 0,
        assists INTEGER DEFAULT 0,
        passes INTEGER DEFAULT 0,
        tackles INTEGER DEFAULT 0,
        minutes_played INTEGER DEFAULT 0,
        rating INTEGER DEFAULT 5,
        notes TEXT,
        created_at TEXT NOT NULL,
        match_type TEXT DEFAULT 'normal'
      )
    ''');

    await db.execute('''
      CREATE TABLE profile(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed sample data
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE training_sessions ADD COLUMN training_type TEXT');
      await db.execute('ALTER TABLE training_sessions ADD COLUMN calories_burned INTEGER');
      await db.execute('ALTER TABLE training_sessions ADD COLUMN heart_rate_avg INTEGER');
      await db.execute('ALTER TABLE training_sessions ADD COLUMN focus_areas TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile(
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE matches ADD COLUMN rating INTEGER DEFAULT 5');
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE matches ADD COLUMN match_type TEXT DEFAULT 'normal'");
    }
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();

    // Seed training sessions
    final sessions = [
      {
        'date': now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
        'duration': 90,
        'intensity': 4,
        'distance': 7.5,
        'location': 'Training Ground A',
        'notes': 'Strong team practice. Focused on pressing.',
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'training_type': 'Tactical',
        'calories_burned': 720,
        'heart_rate_avg': 158,
        'focus_areas': 'Pressing,Positioning,Team Shape',
      },
      {
        'date': now.subtract(const Duration(days: 3)).toIso8601String().split('T')[0],
        'duration': 45,
        'intensity': 3,
        'distance': 3.2,
        'location': 'Gym',
        'notes': 'Strength and conditioning work.',
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'training_type': 'Gym',
        'calories_burned': 380,
        'heart_rate_avg': 135,
        'focus_areas': 'Strength,Core,Agility',
      },
      {
        'date': now.subtract(const Duration(days: 5)).toIso8601String().split('T')[0],
        'duration': 30,
        'intensity': 1,
        'distance': 4.0,
        'location': 'Park',
        'notes': 'Easy recovery run.',
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'training_type': 'Recovery',
        'calories_burned': 210,
        'heart_rate_avg': 112,
        'focus_areas': 'Stamina,Mental Reset',
      },
      {
        'date': now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0],
        'duration': 60,
        'intensity': 5,
        'distance': 8.1,
        'location': 'Main Pitch',
        'notes': 'Sprint intervals, new PB.',
        'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'training_type': 'Fitness',
        'calories_burned': 850,
        'heart_rate_avg': 178,
        'focus_areas': 'Speed,Stamina,Explosiveness',
      },
    ];
    for (final s in sessions) {
      await db.insert('training_sessions', s);
    }

    // Seed matches
    final matches = [
      {
        'date': now.subtract(const Duration(days: 4)).toIso8601String().split('T')[0],
        'opponent': 'Falcons Utd',
        'home_team': 'Eagles FC',
        'home_score': 2,
        'away_score': 1,
        'goals': 1,
        'assists': 0,
        'passes': 42,
        'tackles': 6,
        'minutes_played': 90,
        'notes': 'Strong performance. Scored the winner.',
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'rating': 7,
      },
      {
        'date': now.subtract(const Duration(days: 11)).toIso8601String().split('T')[0],
        'opponent': 'City Rovers',
        'home_team': 'Eagles FC',
        'home_score': 1,
        'away_score': 1,
        'goals': 0,
        'assists': 1,
        'passes': 38,
        'tackles': 4,
        'minutes_played': 80,
        'notes': 'Tough draw. Improved second half.',
        'created_at': now.subtract(const Duration(days: 11)).toIso8601String(),
        'match_type': 'five_a_side',
      },
      {
        'date': now.subtract(const Duration(days: 18)).toIso8601String().split('T')[0],
        'opponent': 'West Strikers',
        'home_team': 'Eagles FC',
        'home_score': 3,
        'away_score': 0,
        'goals': 2,
        'assists': 1,
        'passes': 55,
        'tackles': 2,
        'minutes_played': 90,
        'notes': 'Best game of the season so far.',
        'created_at': now.subtract(const Duration(days: 18)).toIso8601String(),
        'rating': 9,
      },
    ];
    for (final m in matches) {
      await db.insert('matches', m);
    }
  }

  // ─── Training Sessions ───────────────────────────────────────────────────────

  Future<int> insertTrainingSession(TrainingSession session) async {
    final db = await database;
    return await db.insert('training_sessions', session.toMap());
  }

  Future<List<TrainingSession>> getAllTrainingSessions() async {
    final db = await database;
    final maps = await db.query('training_sessions', orderBy: 'date DESC');
    return maps.map(TrainingSession.fromMap).toList();
  }

  Future<int> updateTrainingSession(TrainingSession session) async {
    final db = await database;
    return await db.update(
      'training_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteTrainingSession(int id) async {
    final db = await database;
    return await db.delete('training_sessions', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Matches ─────────────────────────────────────────────────────────────────

  Future<int> insertMatch(Match match) async {
    final db = await database;
    return await db.insert('matches', match.toMap());
  }

  Future<List<Match>> getAllMatches() async {
    final db = await database;
    final maps = await db.query('matches', orderBy: 'date DESC');
    return maps.map(Match.fromMap).toList();
  }

  Future<int> updateMatch(Match match) async {
    final db = await database;
    return await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<int> deleteMatch(int id) async {
    final db = await database;
    return await db.delete('matches', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Stats / Aggregates ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;
    final trainingCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM training_sessions'),
    ) ?? 0;
    final matchCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM matches'),
    ) ?? 0;
    final totalGoals = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(goals) FROM matches'),
    ) ?? 0;
    final totalAssists = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(assists) FROM matches'),
    ) ?? 0;
    final totalPasses = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(passes) FROM matches'),
    ) ?? 0;
    return {
      'trainings': trainingCount,
      'games': matchCount,
      'goals': totalGoals,
      'assists': totalAssists,
      'passes': totalPasses,
    };
  }

  Future<Map<String, dynamic>> getCareerStats() async {
    final db = await database;
    final totalGoals = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(goals) FROM matches'),
    ) ?? 0;
    final totalAssists = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(assists) FROM matches'),
    ) ?? 0;
    final totalPasses = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(passes) FROM matches'),
    ) ?? 0;
    final totalTrainings = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM training_sessions'),
    ) ?? 0;
    final totalTrainingMins = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(duration) FROM training_sessions'),
    ) ?? 0;
    final avgIntensityRaw = await db.rawQuery('SELECT AVG(intensity) FROM training_sessions');
    final avgIntensity = (avgIntensityRaw.first.values.first as num?)?.toDouble() ?? 0.0;

    // Weekly training data (last 7 days)
    final weeklyData = <String, int>{};
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr = day.toIso8601String().split('T')[0];
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT SUM(duration) FROM training_sessions WHERE date = ?",
          [dateStr],
        ),
      ) ?? 0;
      weeklyData[days[(day.weekday - 1) % 7]] = count;
    }

    return {
      'totalGoals': totalGoals,
      'totalAssists': totalAssists,
      'totalPasses': totalPasses,
      'totalTrainings': totalTrainings,
      'totalTrainingMins': totalTrainingMins,
      'avgIntensity': avgIntensity,
      'weeklyData': weeklyData,
    };
  }

  // ─── Profile ─────────────────────────────────────────────────────────────────

  Future<void> setProfileValue(String key, String value) async {
    final db = await database;
    await db.insert(
      'profile',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getProfileValue(String key) async {
    final db = await database;
    final rows = await db.query('profile', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<Map<String, String>> getAllProfileValues() async {
    final db = await database;
    final rows = await db.query('profile');
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }
}
