import 'exercise.dart';

/// Training plan for a single day of the week.
class DaySchedule {
  const DaySchedule({
    required this.weekday,
    required this.exercises,
  });

  /// ISO weekday: 1 = Monday … 7 = Sunday.
  final int weekday;
  final List<ExerciseType> exercises;

  String get weekdayName {
    const names = ['', '週一', '週二', '週三', '週四', '週五', '週六', '週日'];
    return names[weekday];
  }

  DaySchedule copyWith({List<ExerciseType>? exercises}) {
    return DaySchedule(weekday: weekday, exercises: exercises ?? this.exercises);
  }

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'exercises': exercises.map((e) => e.name).toList(),
      };

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      weekday: json['weekday'] as int,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseType.values.byName(e as String))
          .toList(),
    );
  }
}

/// The user's full weekly training schedule.
class TrainingSchedule {
  const TrainingSchedule({required this.days});

  final List<DaySchedule> days;

  List<ExerciseType> exercisesForWeekday(int weekday) {
    try {
      return days.firstWhere((d) => d.weekday == weekday).exercises;
    } catch (_) {
      return [];
    }
  }

  List<ExerciseType> get todaysExercises =>
      exercisesForWeekday(DateTime.now().weekday);

  TrainingSchedule withDay(DaySchedule day) {
    final updated = days.where((d) => d.weekday != day.weekday).toList()
      ..add(day)
      ..sort((a, b) => a.weekday.compareTo(b.weekday));
    return TrainingSchedule(days: updated);
  }

  TrainingSchedule withoutDay(int weekday) {
    return TrainingSchedule(
      days: days.where((d) => d.weekday != weekday).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() => days.map((d) => d.toJson()).toList();

  factory TrainingSchedule.fromJson(List<dynamic> json) {
    return TrainingSchedule(
      days: json
          .map((d) => DaySchedule.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Default: push+squat on Mon/Wed/Fri, pull+bridge+legRaise on Tue/Thu.
  factory TrainingSchedule.defaultSchedule() {
    return const TrainingSchedule(days: [
      DaySchedule(
        weekday: 1,
        exercises: [ExerciseType.pushUp, ExerciseType.squat],
      ),
      DaySchedule(
        weekday: 2,
        exercises: [
          ExerciseType.pullUp,
          ExerciseType.bridge,
          ExerciseType.legRaise,
        ],
      ),
      DaySchedule(
        weekday: 3,
        exercises: [
          ExerciseType.pushUp,
          ExerciseType.squat,
          ExerciseType.handstand,
        ],
      ),
      DaySchedule(
        weekday: 5,
        exercises: [ExerciseType.pushUp, ExerciseType.squat],
      ),
      DaySchedule(
        weekday: 6,
        exercises: [
          ExerciseType.pullUp,
          ExerciseType.bridge,
          ExerciseType.legRaise,
        ],
      ),
    ]);
  }
}
