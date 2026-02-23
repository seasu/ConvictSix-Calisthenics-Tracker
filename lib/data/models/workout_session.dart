import 'exercise.dart';

/// A single logged set within a workout.
class WorkoutSet {
  const WorkoutSet({
    required this.id,
    required this.exercise,
    required this.stepNumber,
    required this.reps,
    required this.timestamp,
    this.holdSeconds = 0,
    this.note = '',
  });

  final String id;
  final ExerciseType exercise;
  final int stepNumber;
  final int reps; // 0 when it's a hold
  final int holdSeconds; // 0 when it's reps
  final DateTime timestamp;
  final String note;

  bool get isHold => holdSeconds > 0;

  String get displayReps => isHold ? '$holdSeconds秒' : '$reps下';

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise': exercise.name,
        'stepNumber': stepNumber,
        'reps': reps,
        'holdSeconds': holdSeconds,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as String,
      exercise: ExerciseType.values.byName(json['exercise'] as String),
      stepNumber: json['stepNumber'] as int,
      reps: json['reps'] as int? ?? 0,
      holdSeconds: json['holdSeconds'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String? ?? '',
    );
  }
}

/// A complete workout session containing multiple sets.
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.date,
    required this.sets,
    this.isCompleted = false,
  });

  final String id;
  final DateTime date;
  final List<WorkoutSet> sets;
  final bool isCompleted;

  /// Exercises performed in this session (deduplicated, in order of first set).
  List<ExerciseType> get exercises {
    final seen = <ExerciseType>{};
    return sets.map((s) => s.exercise).where(seen.add).toList();
  }

  int setsForExercise(ExerciseType type) =>
      sets.where((s) => s.exercise == type).length;

  WorkoutSession copyWith({
    List<WorkoutSet>? sets,
    bool? isCompleted,
  }) {
    return WorkoutSession(
      id: id,
      date: date,
      sets: sets ?? this.sets,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'sets': sets.map((s) => s.toJson()).toList(),
        'isCompleted': isCompleted,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      sets: (json['sets'] as List<dynamic>)
          .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
