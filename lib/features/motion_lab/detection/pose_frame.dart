/// The body landmarks the motion lab's move detectors care about — a small
/// subset of what pose-estimation libraries typically expose. Kept
/// independent of any specific ML library so the detection logic below has
/// zero external dependencies and stays trivially unit-testable.
enum BodyLandmark {
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
}

/// A single detected body point in image coordinates, with the detector's
/// per-landmark confidence score.
class BodyPoint {
  const BodyPoint({required this.x, required this.y, required this.likelihood});

  final double x;
  final double y;
  final double likelihood;
}

/// One frame's worth of detected body landmarks.
typedef PoseFrame = Map<BodyLandmark, BodyPoint>;
