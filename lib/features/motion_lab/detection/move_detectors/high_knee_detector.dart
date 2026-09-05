import 'dart:math' as math;

import '../move_detector.dart';
import '../pose_frame.dart';
import '../pose_math.dart';

/// High knee: vertical gap between hip and knee, normalized by torso length
/// (shoulder-to-hip distance) so it stays meaningful regardless of distance
/// from the camera. Note this signal runs opposite to angle-based
/// detectors — leg extended down gives a large gap, and lifting the knee
/// toward hip height shrinks it toward zero. High knees alternates legs, so
/// each frame takes whichever leg is currently higher (the smaller value).
class HighKneeDetector extends MoveDetector {
  const HighKneeDetector();

  @override
  double? extractSignal(PoseFrame frame) {
    final torsoLength = distanceBetween(
            frame, BodyLandmark.leftShoulder, BodyLandmark.leftHip) ??
        distanceBetween(
            frame, BodyLandmark.rightShoulder, BodyLandmark.rightHip);
    if (torsoLength == null || torsoLength == 0) return null;

    final leftLift = _kneeLift(
        frame, BodyLandmark.leftHip, BodyLandmark.leftKnee, torsoLength);
    final rightLift = _kneeLift(
        frame, BodyLandmark.rightHip, BodyLandmark.rightKnee, torsoLength);
    if (leftLift == null && rightLift == null) return null;
    if (leftLift == null) return rightLift;
    if (rightLift == null) return leftLift;
    return math.min(leftLift, rightLift);
  }

  double? _kneeLift(
    PoseFrame frame,
    BodyLandmark hip,
    BodyLandmark knee,
    double torsoLength,
  ) {
    final hipPoint = reliablePoint(frame, hip);
    final kneePoint = reliablePoint(frame, knee);
    if (hipPoint == null || kneePoint == null) return null;
    return (kneePoint.y - hipPoint.y).abs() / torsoLength;
  }
}
