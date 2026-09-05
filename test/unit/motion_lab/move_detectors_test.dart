import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/motion_lab_exercise.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detectors/high_knee_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detectors/jumping_jack_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detectors/punch_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detectors/pushup_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detectors/situp_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/move_detectors/squat_detector.dart';
import 'package:convict_six_calisthenics_tracker/features/motion_lab/detection/pose_frame.dart';
import 'package:flutter_test/flutter_test.dart';

BodyPoint _p(double x, double y, {double likelihood = 0.9}) =>
    BodyPoint(x: x, y: y, likelihood: likelihood);

void main() {
  group('SquatDetector', () {
    const detector = SquatDetector();

    test('reads a straight leg (standing) as above the up threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftHip: _p(0, 0),
        BodyLandmark.leftKnee: _p(0, 1),
        BodyLandmark.leftAnkle: _p(0, 2),
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.squat.upThreshold));
    });

    test('reads a bent knee (squatting) as below the down threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftHip: _p(0, 0),
        BodyLandmark.leftKnee: _p(0, 1),
        BodyLandmark.leftAnkle: _p(1, 1),
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.squat.downThreshold));
    });

    test('returns null when a required landmark is missing', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftHip: _p(0, 0),
        BodyLandmark.leftKnee: _p(0, 1),
      };
      expect(detector.extractSignal(frame), isNull);
    });

    test('returns null when a landmark is below the confidence threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftHip: _p(0, 0),
        BodyLandmark.leftKnee: _p(0, 1, likelihood: 0.1),
        BodyLandmark.leftAnkle: _p(0, 2),
      };
      expect(detector.extractSignal(frame), isNull);
    });
  });

  group('PushUpDetector', () {
    const detector = PushUpDetector();

    test('reads a straight arm as above the up threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftElbow: _p(0, 1),
        BodyLandmark.leftWrist: _p(0, 2),
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.pushUp.upThreshold));
    });

    test('reads a bent elbow as below the down threshold', () {
      // ~27° at the elbow — clearly bent, not just barely under 90°.
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftElbow: _p(0, 1),
        BodyLandmark.leftWrist: _p(0.1, 0.8),
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.pushUp.downThreshold));
    });
  });

  group('SitUpDetector (signal runs opposite of angle detectors above)', () {
    const detector = SitUpDetector();

    test('reads a flat torso (lying down) as above the down threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftHip: _p(0, 1),
        BodyLandmark.leftKnee: _p(0, 2),
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.sitUp.downThreshold));
    });

    test('reads a folded torso (sitting up) as below the up threshold', () {
      // ~27° at the hip — clearly folded, not just barely under 60°.
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftHip: _p(0, 1),
        BodyLandmark.leftKnee: _p(0.1, 0.8),
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.sitUp.upThreshold));
    });
  });

  group('JumpingJackDetector', () {
    const detector = JumpingJackDetector();

    test('reads arms/legs together as below the down threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(-1, 0),
        BodyLandmark.rightShoulder: _p(1, 0),
        BodyLandmark.leftWrist: _p(-0.5, 0),
        BodyLandmark.rightWrist: _p(0.5, 0),
        BodyLandmark.leftHip: _p(-1, 2),
        BodyLandmark.rightHip: _p(1, 2),
        BodyLandmark.leftAnkle: _p(-0.5, 4),
        BodyLandmark.rightAnkle: _p(0.5, 4),
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.jumpingJack.downThreshold));
    });

    test('reads arms/legs spread wide as above the up threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(-1, 0),
        BodyLandmark.rightShoulder: _p(1, 0),
        BodyLandmark.leftWrist: _p(-3, 0),
        BodyLandmark.rightWrist: _p(3, 0),
        BodyLandmark.leftHip: _p(-1, 2),
        BodyLandmark.rightHip: _p(1, 2),
        BodyLandmark.leftAnkle: _p(-3, 4),
        BodyLandmark.rightAnkle: _p(3, 4),
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.jumpingJack.upThreshold));
    });

    test('falls back to the arm ratio alone when leg landmarks are missing',
        () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(-1, 0),
        BodyLandmark.rightShoulder: _p(1, 0),
        BodyLandmark.leftWrist: _p(-3, 0),
        BodyLandmark.rightWrist: _p(3, 0),
      };
      expect(detector.extractSignal(frame), 3.0);
    });
  });

  group('HighKneeDetector (signal runs opposite of angle detectors above)', () {
    const detector = HighKneeDetector();

    test('reads an extended leg as above the down threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftHip: _p(0, 2),
        BodyLandmark.leftKnee: _p(0, 5),
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.highKnee.downThreshold));
    });

    test('reads a knee lifted to hip height as below the up threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftHip: _p(0, 2),
        BodyLandmark.leftKnee: _p(0, 2.2),
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.highKnee.upThreshold));
    });

    test('takes whichever leg is currently higher', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftHip: _p(0, 2),
        BodyLandmark.leftKnee: _p(0, 2.2), // raised
        BodyLandmark.rightShoulder: _p(0, 0),
        BodyLandmark.rightHip: _p(0, 2),
        BodyLandmark.rightKnee: _p(0, 5), // planted
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.highKnee.upThreshold));
    });
  });

  group('PunchDetector', () {
    const detector = PunchDetector();

    test('reads a fully extended arm as above the up threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftElbow: _p(1, 0),
        BodyLandmark.leftWrist: _p(2, 0),
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.punch.upThreshold));
    });

    test('reads a retracted arm as below the down threshold', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftElbow: _p(1, 0),
        BodyLandmark.leftWrist: _p(0.5, 0.5),
      };
      expect(detector.extractSignal(frame),
          lessThan(MotionLabExercise.punch.downThreshold));
    });

    test('takes whichever arm is currently more extended', () {
      final frame = <BodyLandmark, BodyPoint>{
        BodyLandmark.leftShoulder: _p(0, 0),
        BodyLandmark.leftElbow: _p(1, 0),
        BodyLandmark.leftWrist: _p(2, 0), // extended
        BodyLandmark.rightShoulder: _p(0, 0),
        BodyLandmark.rightElbow: _p(1, 0),
        BodyLandmark.rightWrist: _p(0.5, 0.5), // retracted
      };
      expect(detector.extractSignal(frame),
          greaterThan(MotionLabExercise.punch.upThreshold));
    });
  });
}
