import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/hysteresis_rep_counter.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/pose_frame.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDetector extends MoveDetector {
  _FakeDetector(this.nextSignal);

  double? nextSignal;

  @override
  double? extractSignal(PoseFrame frame) => nextSignal;
}

const _emptyFrame = <BodyLandmark, BodyPoint>{};

void main() {
  group('HysteresisRepCounter (rising signal = up, e.g. squat knee angle)', () {
    late _FakeDetector detector;
    late HysteresisRepCounter counter;

    setUp(() {
      detector = _FakeDetector(170);
      counter = HysteresisRepCounter(
        detector: detector,
        upThreshold: 160,
        downThreshold: 100,
      );
    });

    test('counts 1 rep for a normal down-then-up cycle', () {
      detector.nextSignal = 170; // standing
      expect(counter.onFrame(_emptyFrame), isFalse);

      detector.nextSignal = 90; // squatted down
      expect(counter.onFrame(_emptyFrame), isFalse);

      detector.nextSignal = 170; // back up
      expect(counter.onFrame(_emptyFrame), isTrue);

      expect(counter.reps, 1);
    });

    test('does not double-count jitter near the down threshold', () {
      detector.nextSignal = 170;
      counter.onFrame(_emptyFrame);

      // Dips just below the down threshold, then jitters just above and
      // below it several times before recovering — should stay "down" the
      // whole time without emitting extra reps.
      for (final signal in [98, 101, 97, 102, 96]) {
        detector.nextSignal = signal.toDouble();
        expect(counter.onFrame(_emptyFrame), isFalse);
      }

      detector.nextSignal = 170;
      expect(counter.onFrame(_emptyFrame), isTrue);
      expect(counter.reps, 1);
    });

    test('does not count a partial rep that never reaches the down threshold',
        () {
      detector.nextSignal = 170;
      counter.onFrame(_emptyFrame);

      detector.nextSignal = 140; // half-hearted squat, doesn't cross 100
      expect(counter.onFrame(_emptyFrame), isFalse);

      detector.nextSignal = 170; // back up without ever having gone "down"
      expect(counter.onFrame(_emptyFrame), isFalse);
      expect(counter.reps, 0);
    });

    test('ignores frames with no usable signal instead of changing phase', () {
      detector.nextSignal = 170;
      counter.onFrame(_emptyFrame);

      detector.nextSignal = 90;
      counter.onFrame(_emptyFrame);

      detector.nextSignal = null; // occluded frame mid-rep
      expect(counter.onFrame(_emptyFrame), isFalse);

      detector.nextSignal = 170;
      expect(counter.onFrame(_emptyFrame), isTrue);
      expect(counter.reps, 1);
    });

    test('counts multiple consecutive reps', () {
      for (var i = 0; i < 3; i++) {
        detector.nextSignal = 170;
        counter.onFrame(_emptyFrame);
        detector.nextSignal = 90;
        counter.onFrame(_emptyFrame);
        detector.nextSignal = 170;
        counter.onFrame(_emptyFrame);
      }
      expect(counter.reps, 3);
    });

    test('reset clears the count and phase', () {
      detector.nextSignal = 170;
      counter.onFrame(_emptyFrame);
      detector.nextSignal = 90;
      counter.onFrame(_emptyFrame);
      detector.nextSignal = 170;
      counter.onFrame(_emptyFrame);
      expect(counter.reps, 1);

      counter.reset();
      expect(counter.reps, 0);

      // A fresh cycle after reset should count normally.
      detector.nextSignal = 90;
      counter.onFrame(_emptyFrame);
      detector.nextSignal = 170;
      expect(counter.onFrame(_emptyFrame), isTrue);
      expect(counter.reps, 1);
    });
  });

  group('HysteresisRepCounter (falling signal = up, e.g. sit-up torso angle)',
      () {
    test('counts 1 rep for a lie-down-then-sit-up cycle', () {
      final detector = _FakeDetector(170);
      final counter = HysteresisRepCounter(
        detector: detector,
        upThreshold: 60,
        downThreshold: 130,
      );

      detector.nextSignal = 170; // lying flat
      counter.onFrame(_emptyFrame);

      detector.nextSignal = 50; // sat up
      expect(counter.onFrame(_emptyFrame), isTrue);
      expect(counter.reps, 1);

      detector.nextSignal = 170; // back down
      expect(counter.onFrame(_emptyFrame), isFalse);
      expect(counter.reps, 1);
    });
  });
}
