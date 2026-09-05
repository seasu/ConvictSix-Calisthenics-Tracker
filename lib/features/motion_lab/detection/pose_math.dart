import 'dart:math' as math;

import 'pose_frame.dart';

/// Minimum per-landmark confidence before a point is trusted. Below this,
/// the helpers here return null so a detector can skip the frame instead of
/// counting on noisy data.
const double kMinLandmarkLikelihood = 0.5;

/// Returns [landmark] from [frame] only if it's confidently detected.
BodyPoint? reliablePoint(PoseFrame frame, BodyLandmark landmark) {
  final point = frame[landmark];
  if (point == null || point.likelihood < kMinLandmarkLikelihood) return null;
  return point;
}

/// Returns the interior angle at [b] formed by rays b→a and b→c, in degrees
/// (0-180), or null if any of the three landmarks isn't confidently
/// detected in this frame.
double? angleBetween(
  PoseFrame frame,
  BodyLandmark a,
  BodyLandmark b,
  BodyLandmark c,
) {
  final pa = reliablePoint(frame, a);
  final pb = reliablePoint(frame, b);
  final pc = reliablePoint(frame, c);
  if (pa == null || pb == null || pc == null) return null;

  final v1x = pa.x - pb.x;
  final v1y = pa.y - pb.y;
  final v2x = pc.x - pb.x;
  final v2y = pc.y - pb.y;

  final mag1 = math.sqrt(v1x * v1x + v1y * v1y);
  final mag2 = math.sqrt(v2x * v2x + v2y * v2y);
  if (mag1 == 0 || mag2 == 0) return null;

  final cosAngle = ((v1x * v2x + v1y * v2y) / (mag1 * mag2)).clamp(-1.0, 1.0);
  return math.acos(cosAngle) * 180 / math.pi;
}

/// Euclidean distance between two landmarks, or null if either isn't
/// confidently detected.
double? distanceBetween(PoseFrame frame, BodyLandmark a, BodyLandmark b) {
  final pa = reliablePoint(frame, a);
  final pb = reliablePoint(frame, b);
  if (pa == null || pb == null) return null;
  final dx = pa.x - pb.x;
  final dy = pa.y - pb.y;
  return math.sqrt(dx * dx + dy * dy);
}
