import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import 'detection/pose_frame.dart';

/// Draws the 12 tracked landmarks and the bones between them, scaled from
/// the camera image's pixel coordinates to this painter's rendered size.
///
/// [imageSize] is the *sensor* image's width/height (landscape, before the
/// 90° rotation applied for portrait display) and [mirror] should be true
/// for a front-facing camera shown as a mirror. This mapping covers the
/// common "phone held upright, front camera, portrait-locked" case — it has
/// not been verified against a real device (see `MotionLabScreen`'s doc
/// comment) and may need adjusting once it is.
class PosePainter extends CustomPainter {
  PosePainter({
    required this.frame,
    required this.imageSize,
    required this.mirror,
  });

  final PoseFrame frame;
  final Size imageSize;
  final bool mirror;

  static const _bones = [
    [BodyLandmark.leftShoulder, BodyLandmark.rightShoulder],
    [BodyLandmark.leftShoulder, BodyLandmark.leftElbow],
    [BodyLandmark.leftElbow, BodyLandmark.leftWrist],
    [BodyLandmark.rightShoulder, BodyLandmark.rightElbow],
    [BodyLandmark.rightElbow, BodyLandmark.rightWrist],
    [BodyLandmark.leftShoulder, BodyLandmark.leftHip],
    [BodyLandmark.rightShoulder, BodyLandmark.rightHip],
    [BodyLandmark.leftHip, BodyLandmark.rightHip],
    [BodyLandmark.leftHip, BodyLandmark.leftKnee],
    [BodyLandmark.leftKnee, BodyLandmark.leftAnkle],
    [BodyLandmark.rightHip, BodyLandmark.rightKnee],
    [BodyLandmark.rightKnee, BodyLandmark.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.isEmpty || imageSize.width == 0 || imageSize.height == 0) {
      return;
    }

    final dotPaint = Paint()
      ..color = kPrimary
      ..style = PaintingStyle.fill;
    final bonePaint = Paint()
      ..color = kPrimary.withAlpha(180)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Offset toCanvas(BodyPoint p) {
      // The sensor image is landscape; portrait display rotates it 90°, so
      // the image's Y axis maps to the screen's X axis and vice versa.
      final dx = size.width * (p.y / imageSize.height);
      final dy = size.height * (p.x / imageSize.width);
      return Offset(mirror ? size.width - dx : dx, dy);
    }

    for (final bone in _bones) {
      final a = frame[bone[0]];
      final b = frame[bone[1]];
      if (a == null || b == null) continue;
      canvas.drawLine(toCanvas(a), toCanvas(b), bonePaint);
    }
    for (final point in frame.values) {
      canvas.drawCircle(toCanvas(point), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) => true;
}
