import '../move_detector.dart';
import '../pose_frame.dart';
import '../pose_math.dart';

/// Jumping jack: wrist spread relative to shoulder width, averaged with
/// ankle spread relative to hip width, so either signal alone can drive the
/// count if the other pair is occluded. Arms/legs together (closed) gives a
/// ratio near or below 1; arms/legs spread out (open) pushes it well above 1.
class JumpingJackDetector extends MoveDetector {
  const JumpingJackDetector();

  @override
  double? extractSignal(PoseFrame frame) {
    final armRatio = _ratio(
      frame,
      spreadA: BodyLandmark.leftWrist,
      spreadB: BodyLandmark.rightWrist,
      referenceA: BodyLandmark.leftShoulder,
      referenceB: BodyLandmark.rightShoulder,
    );
    final legRatio = _ratio(
      frame,
      spreadA: BodyLandmark.leftAnkle,
      spreadB: BodyLandmark.rightAnkle,
      referenceA: BodyLandmark.leftHip,
      referenceB: BodyLandmark.rightHip,
    );
    if (armRatio == null && legRatio == null) return null;
    if (armRatio == null) return legRatio;
    if (legRatio == null) return armRatio;
    return (armRatio + legRatio) / 2;
  }

  double? _ratio(
    PoseFrame frame, {
    required BodyLandmark spreadA,
    required BodyLandmark spreadB,
    required BodyLandmark referenceA,
    required BodyLandmark referenceB,
  }) {
    final reference = distanceBetween(frame, referenceA, referenceB);
    final spread = distanceBetween(frame, spreadA, spreadB);
    if (reference == null || reference == 0 || spread == null) return null;
    return spread / reference;
  }
}
