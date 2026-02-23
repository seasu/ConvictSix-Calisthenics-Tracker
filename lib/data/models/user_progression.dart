import 'exercise.dart';

/// Stores the user's current step (1–10) for each of the six exercises.
class UserProgression {
  const UserProgression({required this.currentSteps});

  final Map<ExerciseType, int> currentSteps;

  int stepFor(ExerciseType type) => currentSteps[type] ?? 1;

  UserProgression withStep(ExerciseType type, int step) {
    return UserProgression(
      currentSteps: Map.unmodifiable({
        ...currentSteps,
        type: step.clamp(1, 10),
      }),
    );
  }

  Map<String, dynamic> toJson() => {
        for (final entry in currentSteps.entries) entry.key.name: entry.value,
      };

  factory UserProgression.fromJson(Map<String, dynamic> json) {
    final steps = <ExerciseType, int>{};
    for (final type in ExerciseType.values) {
      final raw = json[type.name];
      steps[type] = (raw as int?)?.clamp(1, 10) ?? 1;
    }
    return UserProgression(currentSteps: Map.unmodifiable(steps));
  }

  factory UserProgression.initial() {
    return UserProgression(
      currentSteps: Map.unmodifiable({
        for (final type in ExerciseType.values) type: 1,
      }),
    );
  }
}
