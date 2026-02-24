import 'exercise.dart';

/// Stores the user's current step (1–10) and training level (0–2) per exercise.
/// Training level: 0 = 入門, 1 = 中級, 2 = 晉級
class UserProgression {
  const UserProgression({
    required this.currentSteps,
    required this.trainingLevels,
  });

  final Map<ExerciseType, int> currentSteps;
  final Map<ExerciseType, int> trainingLevels;

  int stepFor(ExerciseType type) => currentSteps[type] ?? 1;

  /// Returns 0 (入門), 1 (中級), or 2 (晉級). Defaults to 2.
  int trainingLevelFor(ExerciseType type) => trainingLevels[type] ?? 2;

  UserProgression withStep(ExerciseType type, int step) {
    return UserProgression(
      currentSteps: Map.unmodifiable({
        ...currentSteps,
        type: step.clamp(1, 10),
      }),
      trainingLevels: trainingLevels,
    );
  }

  UserProgression withTrainingLevel(ExerciseType type, int level) {
    return UserProgression(
      currentSteps: currentSteps,
      trainingLevels: Map.unmodifiable({
        ...trainingLevels,
        type: level.clamp(0, 2),
      }),
    );
  }

  Map<String, dynamic> toJson() => {
        for (final entry in currentSteps.entries) entry.key.name: entry.value,
        for (final entry in trainingLevels.entries)
          '${entry.key.name}_level': entry.value,
      };

  factory UserProgression.fromJson(Map<String, dynamic> json) {
    final steps = <ExerciseType, int>{};
    final levels = <ExerciseType, int>{};
    for (final type in ExerciseType.values) {
      final rawStep = json[type.name];
      steps[type] = (rawStep as int?)?.clamp(1, 10) ?? 1;
      final rawLevel = json['${type.name}_level'];
      levels[type] = (rawLevel as int?)?.clamp(0, 2) ?? 2;
    }
    return UserProgression(
      currentSteps: Map.unmodifiable(steps),
      trainingLevels: Map.unmodifiable(levels),
    );
  }

  factory UserProgression.initial() {
    return UserProgression(
      currentSteps: Map.unmodifiable({
        for (final type in ExerciseType.values) type: 1,
      }),
      trainingLevels: Map.unmodifiable({
        for (final type in ExerciseType.values) type: 2,
      }),
    );
  }
}
