import 'dart:math' as math;

import '../move_detector.dart';
import '../pose_frame.dart';
import '../pose_math.dart';

/// Punch: straight-line shoulder-to-wrist distance divided by total arm
/// length (upper arm + forearm). Arm retracted near the body gives a ratio
/// well below 1; a fully extended punch pushes it close to 1. Punches
/// alternate arms, so each frame takes whichever arm is currently more
/// extended (the larger ratio).
class PunchDetector extends MoveDetector {
  const PunchDetector();

  @override
  double? extractSignal(PoseFrame frame) {
    final left = _extensionRatio(
      frame,
      shoulder: BodyLandmark.leftShoulder,
      elbow: BodyLandmark.leftElbow,
      wrist: BodyLandmark.leftWrist,
    );
    final right = _extensionRatio(
      frame,
      shoulder: BodyLandmark.rightShoulder,
      elbow: BodyLandmark.rightElbow,
      wrist: BodyLandmark.rightWrist,
    );
    if (left == null && right == null) return null;
    if (left == null) return right;
    if (right == null) return left;
    return math.max(left, right);
  }

  double? _extensionRatio(
    PoseFrame frame, {
    required BodyLandmark shoulder,
    required BodyLandmark elbow,
    required BodyLandmark wrist,
  }) {
    final upperArm = distanceBetween(frame, shoulder, elbow);
    final forearm = distanceBetween(frame, elbow, wrist);
    final reach = distanceBetween(frame, shoulder, wrist);
    if (upperArm == null || forearm == null || reach == null) return null;
    final armLength = upperArm + forearm;
    if (armLength == 0) return null;
    return reach / armLength;
  }
}
