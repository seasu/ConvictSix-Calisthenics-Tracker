import '../move_detector.dart';
import '../pose_frame.dart';
import '../pose_math.dart';

/// Push-up: elbow angle (shoulder-elbow-wrist). Arms straight (top of the
/// rep) is close to 180°, elbows bent (bottom of the rep) drops to around
/// 90° or below. Averages left/right arm when both are visible.
class PushUpDetector extends MoveDetector {
  const PushUpDetector();

  @override
  double? extractSignal(PoseFrame frame) {
    final left = angleBetween(frame, BodyLandmark.leftShoulder,
        BodyLandmark.leftElbow, BodyLandmark.leftWrist);
    final right = angleBetween(frame, BodyLandmark.rightShoulder,
        BodyLandmark.rightElbow, BodyLandmark.rightWrist);
    if (left == null && right == null) return null;
    if (left == null) return right;
    if (right == null) return left;
    return (left + right) / 2;
  }
}
