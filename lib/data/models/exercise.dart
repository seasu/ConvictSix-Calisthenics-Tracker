/// The six movements (六招) of the calisthenics progression system.
enum ExerciseType {
  pushUp, // 伏地挺身
  squat, // 深蹲
  pullUp, // 引體向上
  legRaise, // 舉腿
  bridge, // 橋式
  handstand, // 倒立推
}

extension ExerciseTypeExtension on ExerciseType {
  String get nameZh {
    switch (this) {
      case ExerciseType.pushUp:
        return '伏地挺身';
      case ExerciseType.squat:
        return '深蹲';
      case ExerciseType.pullUp:
        return '引體向上';
      case ExerciseType.legRaise:
        return '舉腿';
      case ExerciseType.bridge:
        return '橋式';
      case ExerciseType.handstand:
        return '倒立推';
    }
  }

  String get nameEn {
    switch (this) {
      case ExerciseType.pushUp:
        return 'Push-up';
      case ExerciseType.squat:
        return 'Squat';
      case ExerciseType.pullUp:
        return 'Pull-up';
      case ExerciseType.legRaise:
        return 'Leg Raise';
      case ExerciseType.bridge:
        return 'Bridge';
      case ExerciseType.handstand:
        return 'Handstand Push-up';
    }
  }

  String get emoji {
    switch (this) {
      case ExerciseType.pushUp:
        return '💪';
      case ExerciseType.squat:
        return '🦵';
      case ExerciseType.pullUp:
        return '🏋️';
      case ExerciseType.legRaise:
        return '🦶';
      case ExerciseType.bridge:
        return '🌉';
      case ExerciseType.handstand:
        return '🤸';
    }
  }
}

/// Describes a training standard: how many sets and reps (or hold seconds).
class StepStandard {
  const StepStandard.reps({required this.sets, required this.reps})
      : holdSeconds = 0;

  const StepStandard.hold({required this.sets, required this.holdSeconds})
      : reps = 0;

  final int sets;
  final int reps;
  final int holdSeconds;

  bool get isHold => holdSeconds > 0;

  String get display {
    if (isHold) return '$sets組 × $holdSeconds秒';
    return '$sets組 × $reps下';
  }
}

/// One of the ten progression steps (十式) within a single exercise.
class ExerciseStep {
  const ExerciseStep({
    required this.stepNumber,
    required this.nameZh,
    required this.nameEn,
    required this.description,
    required this.beginner,
    required this.intermediate,
    required this.progression,
  });

  final int stepNumber; // 1–10
  final String nameZh;
  final String nameEn;
  final String description;
  final StepStandard beginner;
  final StepStandard intermediate;
  final StepStandard progression; // graduation criterion
}

/// A full exercise definition containing all ten steps.
class Exercise {
  const Exercise({
    required this.type,
    required this.steps,
  });

  final ExerciseType type;
  final List<ExerciseStep> steps; // always 10 entries

  String get nameZh => type.nameZh;
  String get nameEn => type.nameEn;
  String get emoji => type.emoji;

  ExerciseStep stepAt(int stepNumber) => steps[stepNumber - 1];
}
