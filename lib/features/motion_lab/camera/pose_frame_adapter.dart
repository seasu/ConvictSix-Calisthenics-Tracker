import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;

import '../detection/pose_frame.dart';

const Map<mlkit.PoseLandmarkType, BodyLandmark> _landmarkMap = {
  mlkit.PoseLandmarkType.leftShoulder: BodyLandmark.leftShoulder,
  mlkit.PoseLandmarkType.rightShoulder: BodyLandmark.rightShoulder,
  mlkit.PoseLandmarkType.leftElbow: BodyLandmark.leftElbow,
  mlkit.PoseLandmarkType.rightElbow: BodyLandmark.rightElbow,
  mlkit.PoseLandmarkType.leftWrist: BodyLandmark.leftWrist,
  mlkit.PoseLandmarkType.rightWrist: BodyLandmark.rightWrist,
  mlkit.PoseLandmarkType.leftHip: BodyLandmark.leftHip,
  mlkit.PoseLandmarkType.rightHip: BodyLandmark.rightHip,
  mlkit.PoseLandmarkType.leftKnee: BodyLandmark.leftKnee,
  mlkit.PoseLandmarkType.rightKnee: BodyLandmark.rightKnee,
  mlkit.PoseLandmarkType.leftAnkle: BodyLandmark.leftAnkle,
  mlkit.PoseLandmarkType.rightAnkle: BodyLandmark.rightAnkle,
};

/// Maps an ML Kit [mlkit.Pose] onto this feature's library-independent
/// [PoseFrame], keeping [MoveDetector]s decoupled from the specific pose
/// library in use.
PoseFrame poseFrameFrom(mlkit.Pose pose) {
  final frame = <BodyLandmark, BodyPoint>{};
  for (final entry in _landmarkMap.entries) {
    final landmark = pose.landmarks[entry.key];
    if (landmark == null) continue;
    frame[entry.value] = BodyPoint(
        x: landmark.x, y: landmark.y, likelihood: landmark.likelihood);
  }
  return frame;
}
