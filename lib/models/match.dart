class Match {
  final int? id;
  final String date;
  final String opponent;
  final String homeTeam;
  final int homeScore;
  final int awayScore;
  final int goals;
  final int assists;
  final int passes;
  final int tackles;
  final int minutesPlayed;
  final int rating;
  final String? notes;
  final String createdAt;
  final String matchType; // 'normal' or 'five_a_side'

  bool get isFiveASide => matchType == 'five_a_side';
  String get matchTypeLabel => isFiveASide ? '5-a-Side' : 'Normal Match';

  const Match({
    this.id,
    required this.date,
    required this.opponent,
    required this.homeTeam,
    required this.homeScore,
    required this.awayScore,
    required this.goals,
    required this.assists,
    required this.passes,
    required this.tackles,
    required this.minutesPlayed,
    this.rating = 5,
    this.notes,
    required this.createdAt,
    this.matchType = 'normal',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date': date,
    'opponent': opponent,
    'home_team': homeTeam,
    'home_score': homeScore,
    'away_score': awayScore,
    'goals': goals,
    'assists': assists,
    'passes': passes,
    'tackles': tackles,
    'minutes_played': minutesPlayed,
    'rating': rating,
    'notes': notes,
    'created_at': createdAt,
    'match_type': matchType,
  };

  static Match fromMap(Map<String, dynamic> map) => Match(
    id: map['id'] as int?,
    date: map['date'] as String,
    opponent: map['opponent'] as String,
    homeTeam: map['home_team'] as String,
    homeScore: map['home_score'] as int,
    awayScore: map['away_score'] as int,
    goals: map['goals'] as int,
    assists: map['assists'] as int,
    passes: map['passes'] as int,
    tackles: map['tackles'] as int,
    minutesPlayed: map['minutes_played'] as int,
    rating: map['rating'] as int? ?? 5,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as String,
    matchType: map['match_type'] as String? ?? 'normal',
  );

  Match copyWith({
    int? id,
    String? date,
    String? opponent,
    String? homeTeam,
    int? homeScore,
    int? awayScore,
    int? goals,
    int? assists,
    int? passes,
    int? tackles,
    int? minutesPlayed,
    int? rating,
    String? notes,
    String? createdAt,
    String? matchType,
  }) => Match(
    id: id ?? this.id,
    date: date ?? this.date,
    opponent: opponent ?? this.opponent,
    homeTeam: homeTeam ?? this.homeTeam,
    homeScore: homeScore ?? this.homeScore,
    awayScore: awayScore ?? this.awayScore,
    goals: goals ?? this.goals,
    assists: assists ?? this.assists,
    passes: passes ?? this.passes,
    tackles: tackles ?? this.tackles,
    minutesPlayed: minutesPlayed ?? this.minutesPlayed,
    rating: rating ?? this.rating,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    matchType: matchType ?? this.matchType,
  );

  String get result {
    if (homeScore > awayScore) return 'Win';
    if (homeScore < awayScore) return 'Loss';
    return 'Draw';
  }
}
