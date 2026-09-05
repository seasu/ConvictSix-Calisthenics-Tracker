import 'move_detector.dart';
import 'move_detectors/high_knee_detector.dart';
import 'move_detectors/jumping_jack_detector.dart';
import 'move_detectors/punch_detector.dart';
import 'move_detectors/pushup_detector.dart';
import 'move_detectors/situp_detector.dart';
import 'move_detectors/squat_detector.dart';

/// The 6 exercises the motion detection lab can count reps for, chosen for
/// being easy for a single phone camera to frame and track — not the same
/// list as ConvictSix's six progressions (pull-up/leg-raise need a bar,
/// bridge/handstand are hard for a static camera to read reliably).
///
/// [upThreshold]/[downThreshold] are first-guess values based on typical
/// body proportions, not yet calibrated against real people on real
/// devices — expect to retune them after on-device testing.
enum MotionLabExercise {
  squat(
    nameZh: '深蹲',
    detector: SquatDetector(),
    upThreshold: 160,
    downThreshold: 100,
  ),
  pushUp(
    nameZh: '伏地挺身',
    detector: PushUpDetector(),
    upThreshold: 160,
    downThreshold: 90,
  ),
  sitUp(
    nameZh: '仰臥起坐',
    detector: SitUpDetector(),
    upThreshold: 60,
    downThreshold: 130,
  ),
  jumpingJack(
    nameZh: '開合跳',
    detector: JumpingJackDetector(),
    upThreshold: 1.8,
    downThreshold: 0.9,
  ),
  highKnee(
    nameZh: '抬膝',
    detector: HighKneeDetector(),
    upThreshold: 0.35,
    downThreshold: 0.85,
  ),
  punch(
    nameZh: '原地衝拳',
    detector: PunchDetector(),
    upThreshold: 0.9,
    downThreshold: 0.6,
  );

  const MotionLabExercise({
    required this.nameZh,
    required this.detector,
    required this.upThreshold,
    required this.downThreshold,
  });

  final String nameZh;
  final MoveDetector detector;
  final double upThreshold;
  final double downThreshold;
}
