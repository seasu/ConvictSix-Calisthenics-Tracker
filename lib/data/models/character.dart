import 'exercise.dart';
import 'user_progression.dart';

enum CharacterType {
  male,
  female,
  child,
  cat,
  dog;

  String get nameZh => switch (this) {
        CharacterType.male => '男生',
        CharacterType.female => '女生',
        CharacterType.child => '小孩',
        CharacterType.cat => '貓貓',
        CharacterType.dog => '狗狗',
      };

  static CharacterType fromKey(String key) => CharacterType.values.firstWhere(
        (t) => t.name == key,
        orElse: () => CharacterType.male,
      );
}

/// Returns 1–5 based on the average step across all six exercises.
int characterStageFor(UserProgression progression) {
  final total = ExerciseType.values
      .map((t) => progression.stepFor(t))
      .fold(0, (a, b) => a + b);
  final avg = total / ExerciseType.values.length;
  if (avg <= 2) return 1;
  if (avg <= 4) return 2;
  if (avg <= 6) return 3;
  if (avg <= 8) return 4;
  return 5;
}

String stageTitle(int stage) => switch (stage) {
      1 => '初學者',
      2 => '見習生',
      3 => '訓練者',
      4 => '強  者',
      _ => '征服者',
    };

String stageSubtitle(int stage) => switch (stage) {
      1 => '剛踏上鍛煉之路',
      2 => '基礎逐漸紮實',
      3 => '身體開始改變',
      4 => '實力今非昔比',
      _ => '已達巔峰境界！',
    };
