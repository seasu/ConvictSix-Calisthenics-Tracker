import 'move_detector.dart';
import 'pose_frame.dart';

enum _RepPhase { up, down }

/// Counts full up→down→up cycles of a [MoveDetector]'s signal using two
/// thresholds (hysteresis) instead of one, so noise near a single cutoff
/// can't trigger multiple counts for one real rep.
///
/// [upThreshold] is the signal value that counts as "up" (rep-ready) and
/// [downThreshold] is the value that counts as "down" (rep started). Pass
/// upThreshold > downThreshold when the signal is larger in the "up"
/// position (e.g. squat knee angle: straight ~170°, bent ~90°), or
/// upThreshold < downThreshold when it's the other way around (e.g. sit-up
/// torso angle, which shrinks as you sit up).
class HysteresisRepCounter {
  HysteresisRepCounter({
    required this.detector,
    required this.upThreshold,
    required this.downThreshold,
  })  : assert(upThreshold != downThreshold),
        _risingIsUp = upThreshold > downThreshold;

  final MoveDetector detector;
  final double upThreshold;
  final double downThreshold;
  final bool _risingIsUp;

  _RepPhase _phase = _RepPhase.up;
  int _reps = 0;

  int get reps => _reps;

  bool _atUp(double signal) =>
      _risingIsUp ? signal >= upThreshold : signal <= upThreshold;

  bool _atDown(double signal) =>
      _risingIsUp ? signal <= downThreshold : signal >= downThreshold;

  /// Feeds one frame's landmarks in. Returns true iff this frame completed
  /// a rep (crossed back to "up" after having reached "down"). Frames with
  /// no usable signal (occluded/low-confidence landmarks) are ignored
  /// rather than treated as a phase change.
  bool onFrame(PoseFrame frame) {
    final signal = detector.extractSignal(frame);
    if (signal == null) return false;

    if (_phase == _RepPhase.up && _atDown(signal)) {
      _phase = _RepPhase.down;
      return false;
    }
    if (_phase == _RepPhase.down && _atUp(signal)) {
      _phase = _RepPhase.up;
      _reps++;
      return true;
    }
    return false;
  }

  void reset() {
    _reps = 0;
    _phase = _RepPhase.up;
  }
}
