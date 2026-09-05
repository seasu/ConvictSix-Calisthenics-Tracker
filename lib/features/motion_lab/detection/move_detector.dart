import 'pose_frame.dart';

/// Extracts one directional "how open/extended is this movement" signal
/// from a pose frame for a single exercise.
///
/// Higher values mean the "up"/extended position (e.g. standing tall, arms
/// straight); lower values mean the "down"/contracted position (e.g.
/// squatting low, elbows bent) — except where a detector's own doc comment
/// says its signal runs the other way (e.g. sit-up, high knee). Callers
/// match this against [HysteresisRepCounter]'s thresholds to count reps.
/// Returns null when the frame doesn't have enough confidently-detected
/// landmarks to compute a signal — callers should skip such frames rather
/// than treat null as either extreme.
abstract class MoveDetector {
  const MoveDetector();

  double? extractSignal(PoseFrame frame);
}
