import '../move_detector.dart';
import '../pose_frame.dart';
import '../pose_math.dart';

/// Sit-up: torso angle (shoulder-hip-knee). Note this signal runs opposite
/// to most other detectors — lying flat opens the angle toward 180°, and
/// sitting up closes it down toward 60-90° as the torso folds over the
/// thighs. Averages left/right side when both are visible.
class SitUpDetector extends MoveDetector {
  const SitUpDetector();

  @override
  double? extractSignal(PoseFrame frame) {
    final left = angleBetween(frame, BodyLandmark.leftShoulder,
        BodyLandmark.leftHip, BodyLandmark.leftKnee);
    final right = angleBetween(frame, BodyLandmark.rightShoulder,
        BodyLandmark.rightHip, BodyLandmark.rightKnee);
    if (left == null && right == null) return null;
    if (left == null) return right;
    if (right == null) return left;
    return (left + right) / 2;
  }
}
