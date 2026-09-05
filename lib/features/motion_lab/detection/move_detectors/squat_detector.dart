import '../move_detector.dart';
import '../pose_frame.dart';
import '../pose_math.dart';

/// Squat: knee angle (hip-knee-ankle). Standing tall is close to 180°, a
/// deep squat drops to around 90° or below. Averages left/right leg when
/// both are visible, for robustness against one noisy landmark.
class SquatDetector extends MoveDetector {
  const SquatDetector();

  @override
  double? extractSignal(PoseFrame frame) {
    final left = angleBetween(frame, BodyLandmark.leftHip,
        BodyLandmark.leftKnee, BodyLandmark.leftAnkle);
    final right = angleBetween(frame, BodyLandmark.rightHip,
        BodyLandmark.rightKnee, BodyLandmark.rightAnkle);
    if (left == null && right == null) return null;
    if (left == null) return right;
    if (right == null) return left;
    return (left + right) / 2;
  }
}
