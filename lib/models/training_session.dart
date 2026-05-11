class TrainingSession {
  final int? id;
  final String date;
  final int duration;        // minutes
  final int intensity;       // 1-5
  final double? distance;    // km
  final String? location;
  final String? notes;
  final String createdAt;
  // New enriched fields
  final String? trainingType;   // e.g. 'Tactical', 'Fitness', 'Technical', 'Match Prep', 'Recovery', 'Gym'
  final int? caloriesBurned;
  final int? heartRateAvg;      // bpm
  final String? focusAreas;     // comma-separated e.g. 'Dribbling,Pressing,Stamina'

  const TrainingSession({
    this.id,
    required this.date,
    required this.duration,
    required this.intensity,
    this.distance,
    this.location,
    this.notes,
    required this.createdAt,
    this.trainingType,
    this.caloriesBurned,
    this.heartRateAvg,
    this.focusAreas,
  });

  List<String> get focusAreaList =>
      (focusAreas != null && focusAreas!.isNotEmpty)
          ? focusAreas!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : [];

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date': date,
    'duration': duration,
    'intensity': intensity,
    'distance': distance,
    'location': location,
    'notes': notes,
    'created_at': createdAt,
    'training_type': trainingType,
    'calories_burned': caloriesBurned,
    'heart_rate_avg': heartRateAvg,
    'focus_areas': focusAreas,
  };

  static TrainingSession fromMap(Map<String, dynamic> map) => TrainingSession(
    id: map['id'] as int?,
    date: map['date'] as String,
    duration: map['duration'] as int,
    intensity: map['intensity'] as int,
    distance: (map['distance'] as num?)?.toDouble(),
    location: map['location'] as String?,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as String,
    trainingType: map['training_type'] as String?,
    caloriesBurned: map['calories_burned'] as int?,
    heartRateAvg: map['heart_rate_avg'] as int?,
    focusAreas: map['focus_areas'] as String?,
  );

  TrainingSession copyWith({
    int? id,
    String? date,
    int? duration,
    int? intensity,
    double? distance,
    String? location,
    String? notes,
    String? createdAt,
    String? trainingType,
    int? caloriesBurned,
    int? heartRateAvg,
    String? focusAreas,
  }) => TrainingSession(
    id: id ?? this.id,
    date: date ?? this.date,
    duration: duration ?? this.duration,
    intensity: intensity ?? this.intensity,
    distance: distance ?? this.distance,
    location: location ?? this.location,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    trainingType: trainingType ?? this.trainingType,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    heartRateAvg: heartRateAvg ?? this.heartRateAvg,
    focusAreas: focusAreas ?? this.focusAreas,
  );

  String get intensityLabel {
    switch (intensity) {
      case 1: return 'Recovery';
      case 2: return 'Low';
      case 3: return 'Medium';
      case 4: return 'High';
      case 5: return 'All Out';
      default: return 'Unknown';
    }
  }
}
