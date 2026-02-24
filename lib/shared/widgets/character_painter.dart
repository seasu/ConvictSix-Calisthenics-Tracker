import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/character.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

/// Renders a cute chibi character whose appearance evolves with [stage] (1–5).
class CharacterWidget extends StatelessWidget {
  const CharacterWidget({
    super.key,
    required this.type,
    required this.stage,
    this.width = 80,
    this.height = 110,
  });

  final CharacterType type;
  final int stage;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: CharacterPainter(type: type, stage: stage.clamp(1, 5)),
      ),
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class CharacterPainter extends CustomPainter {
  const CharacterPainter({required this.type, required this.stage});

  final CharacterType type;
  final int stage; // 1–5

  // ── Virtual canvas (120 × 160) ─────────────────────────────────────────────
  static const double _cx = 60.0; // center x
  static const double _hy = 42.0; // head center y
  static const double _hr = 28.0; // head radius

  // ── Body proportions by stage ──────────────────────────────────────────────
  static const _bwByStage = [0.0, 26.0, 30.0, 34.0, 40.0, 46.0];
  static const _bhByStage = [0.0, 40.0, 44.0, 48.0, 52.0, 56.0];

  double get _bw => _bwByStage[stage];
  double get _bh => _bhByStage[stage];
  double get _bt => _hy + _hr + 4; // body top y
  double get _bl => _cx - _bw / 2; // body left x

  // ── Colours per character type ─────────────────────────────────────────────
  Color get _primary => switch (type) {
        CharacterType.male => const Color(0xFF42A5F5),
        CharacterType.female => const Color(0xFFEC407A),
        CharacterType.child => const Color(0xFFFFCA28),
        CharacterType.cat => const Color(0xFFFF7043),
        CharacterType.dog => const Color(0xFF8D6E63),
      };

  Color get _skin => switch (type) {
        CharacterType.cat => const Color(0xFFFF8A65),
        CharacterType.dog => const Color(0xFFBCAAA4),
        _ => const Color(0xFFFFCC80),
      };

  Color get _hair => switch (type) {
        CharacterType.male => const Color(0xFF4E342E),
        CharacterType.female => const Color(0xFF6D4C41),
        CharacterType.child => const Color(0xFF8D6E63),
        _ => _skin,
      };

  // ── Entry point ────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120.0, size.height / 160.0);
    if (type == CharacterType.cat || type == CharacterType.dog) {
      _paintAnimal(canvas);
    } else {
      _paintHuman(canvas);
    }
    canvas.restore();
  }

  void _paintHuman(Canvas canvas) {
    _drawBodyHuman(canvas);
    _drawNeck(canvas);
    _drawHead(canvas);
    _drawHair(canvas);
    _drawFace(canvas);
    _drawAccessories(canvas);
  }

  void _paintAnimal(Canvas canvas) {
    _drawBodyAnimal(canvas);
    _drawAnimalEars(canvas);
    _drawHead(canvas);
    _drawFace(canvas);
    _drawAnimalExtras(canvas);
    _drawAccessories(canvas);
  }

  // ── Human body ─────────────────────────────────────────────────────────────

  void _drawBodyHuman(Canvas canvas) {
    final paint = Paint()..color = _primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_bl, _bt, _bw, _bh),
        const Radius.circular(8),
      ),
      paint,
    );
    if (stage >= 3) _drawArms(canvas);
    _drawLegs(canvas);
  }

  void _drawArms(Canvas canvas) {
    final armW = stage >= 5 ? 10.0 : stage >= 4 ? 8.0 : 6.0;
    const armH = 22.0;
    final paint = Paint()..color = _primary;
    final handPaint = Paint()..color = _skin;

    if (stage == 5) {
      // Flexed arms angled upward
      _drawRoundRect(canvas, _bl - armW - 4, _bt - 10, armW, armH, 4, paint);
      _drawRoundRect(
          canvas, _bl + _bw + 4, _bt - 10, armW, armH, 4, paint);
      canvas.drawCircle(
          Offset(_bl - armW / 2 - 4, _bt - 10 + armH), 5, handPaint);
      canvas.drawCircle(
          Offset(_bl + _bw + 4 + armW / 2, _bt - 10 + armH), 5, handPaint);
    } else {
      _drawRoundRect(canvas, _bl - armW - 2, _bt + 4, armW, armH, 4, paint);
      _drawRoundRect(
          canvas, _bl + _bw + 2, _bt + 4, armW, armH, 4, paint);
      canvas.drawCircle(
          Offset(_bl - armW / 2 - 2, _bt + 4 + armH), 5, handPaint);
      canvas.drawCircle(
          Offset(_bl + _bw + 2 + armW / 2, _bt + 4 + armH), 5, handPaint);
    }
  }

  void _drawLegs(Canvas canvas) {
    final legW = _bw / 2 - 2;
    final legPaint = Paint()..color = _primary.withValues(alpha: 0.75);
    final shoePaint = Paint()..color = const Color(0xFF37474F);
    final legTop = _bt + _bh - 4;

    _drawRoundRect(canvas, _bl + 1, legTop, legW, 22, 5, legPaint);
    _drawRoundRect(
        canvas, _bl + _bw - legW - 1, legTop, legW, 22, 5, legPaint);
    _drawRoundRect(canvas, _bl - 1, legTop + 20, legW + 4, 8, 4, shoePaint);
    _drawRoundRect(
        canvas, _bl + _bw - legW - 3, legTop + 20, legW + 4, 8, 4, shoePaint);
  }

  void _drawNeck(Canvas canvas) {
    final paint = Paint()..color = _skin;
    canvas.drawRect(
      Rect.fromLTWH(_cx - 6, _hy + _hr - 2, 12, 10),
      paint,
    );
  }

  // ── Animal body ────────────────────────────────────────────────────────────

  void _drawBodyAnimal(Canvas canvas) {
    final paint = Paint()..color = _skin;
    final bodyTop = _hy + _hr - 6.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_bl, bodyTop, _bw, _bh),
        Radius.circular(_bw / 2.2),
      ),
      paint,
    );
    _drawPaws(canvas, bodyTop + _bh);
  }

  void _drawPaws(Canvas canvas, double pawY) {
    final outer = Paint()..color = _skin;
    final inner = Paint()..color = _primary.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(_cx - 14, pawY - 2), 10, outer);
    canvas.drawCircle(Offset(_cx + 14, pawY - 2), 10, outer);
    canvas.drawCircle(Offset(_cx - 14, pawY - 2), 6, inner);
    canvas.drawCircle(Offset(_cx + 14, pawY - 2), 6, inner);
  }

  // ── Head ───────────────────────────────────────────────────────────────────

  void _drawHead(Canvas canvas) {
    canvas.drawCircle(
      const Offset(_cx, _hy),
      _hr,
      Paint()..color = _skin,
    );
  }

  // ── Hair (humans only) ─────────────────────────────────────────────────────

  void _drawHair(Canvas canvas) {
    final paint = Paint()..color = _hair;
    switch (type) {
      case CharacterType.male:
        final path = Path()
          ..moveTo(_cx - _hr * 0.9, _hy - _hr * 0.25)
          ..quadraticBezierTo(
              _cx, _hy - _hr * 1.15, _cx + _hr * 0.9, _hy - _hr * 0.25)
          ..close();
        canvas.drawPath(path, paint);
      case CharacterType.female:
        // Top
        final top = Path()
          ..moveTo(_cx - _hr * 0.9, _hy - _hr * 0.3)
          ..quadraticBezierTo(
              _cx, _hy - _hr * 1.2, _cx + _hr * 0.9, _hy - _hr * 0.3)
          ..close();
        canvas.drawPath(top, paint);
        // Side strands
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(_cx - _hr - 1, _hy + 6), width: 13, height: 30),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(_cx + _hr + 1, _hy + 6), width: 13, height: 30),
          paint,
        );
      case CharacterType.child:
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(_cx, _hy - 4),
              width: _hr * 2 + 6,
              height: _hr * 1.4),
          math.pi,
          math.pi,
          true,
          paint,
        );
      default:
        break;
    }
  }

  // ── Animal ears ────────────────────────────────────────────────────────────

  void _drawAnimalEars(Canvas canvas) {
    if (type == CharacterType.cat) _drawCatEars(canvas);
    if (type == CharacterType.dog) _drawDogEars(canvas);
  }

  void _drawCatEars(Canvas canvas) {
    final outer = Paint()..color = _skin;
    final inner = Paint()..color = _primary.withValues(alpha: 0.55);

    // Left ear
    final leftOuter = Path()
      ..moveTo(_cx - _hr * 0.55, _hy - _hr * 0.55)
      ..lineTo(_cx - _hr * 0.9, _hy - _hr * 1.45)
      ..lineTo(_cx - _hr * 0.05, _hy - _hr * 0.9)
      ..close();
    final leftInner = Path()
      ..moveTo(_cx - _hr * 0.52, _hy - _hr * 0.6)
      ..lineTo(_cx - _hr * 0.82, _hy - _hr * 1.28)
      ..lineTo(_cx - _hr * 0.1, _hy - _hr * 0.88)
      ..close();

    // Right ear
    final rightOuter = Path()
      ..moveTo(_cx + _hr * 0.55, _hy - _hr * 0.55)
      ..lineTo(_cx + _hr * 0.9, _hy - _hr * 1.45)
      ..lineTo(_cx + _hr * 0.05, _hy - _hr * 0.9)
      ..close();
    final rightInner = Path()
      ..moveTo(_cx + _hr * 0.52, _hy - _hr * 0.6)
      ..lineTo(_cx + _hr * 0.82, _hy - _hr * 1.28)
      ..lineTo(_cx + _hr * 0.1, _hy - _hr * 0.88)
      ..close();

    canvas.drawPath(leftOuter, outer);
    canvas.drawPath(rightOuter, outer);
    canvas.drawPath(leftInner, inner);
    canvas.drawPath(rightInner, inner);
  }

  void _drawDogEars(Canvas canvas) {
    final paint = Paint()..color = _skin;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(_cx - _hr * 1.1, _hy + 6), width: 18, height: 32),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(_cx + _hr * 1.1, _hy + 6), width: 18, height: 32),
      paint,
    );
  }

  // ── Face ───────────────────────────────────────────────────────────────────

  void _drawFace(Canvas canvas) {
    _drawEyes(canvas);
    _drawNoseAndMouth(canvas);
    if (type == CharacterType.cat) _drawWhiskers(canvas);
    if (stage == 1) _drawBlush(canvas);
  }

  void _drawEyes(Canvas canvas) {
    const eyeY = _hy - 3.0;
    const gap = 9.5;
    final stroke = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (stage) {
      case 1:
        // Droopy U-arcs
        canvas.drawArc(
            Rect.fromCenter(
                center: const Offset(_cx - gap, eyeY), width: 10, height: 7),
            0,
            math.pi,
            false,
            stroke);
        canvas.drawArc(
            Rect.fromCenter(
                center: const Offset(_cx + gap, eyeY), width: 10, height: 7),
            0,
            math.pi,
            false,
            stroke);
      case 2:
        final p = Paint()..color = const Color(0xFF212121);
        canvas.drawCircle(const Offset(_cx - gap, eyeY), 3, p);
        canvas.drawCircle(const Offset(_cx + gap, eyeY), 3, p);
      case 3:
        _shinyEye(canvas, _cx - gap, eyeY, 4.5);
        _shinyEye(canvas, _cx + gap, eyeY, 4.5);
      case 4:
        _shinyEye(canvas, _cx - gap, eyeY, 5.5);
        _shinyEye(canvas, _cx + gap, eyeY, 5.5);
      default:
        _starEye(canvas, _cx - gap, eyeY);
        _starEye(canvas, _cx + gap, eyeY);
    }
  }

  void _shinyEye(Canvas canvas, double x, double y, double r) {
    canvas.drawCircle(
        Offset(x, y), r, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(x - r * 0.38, y - r * 0.38), r * 0.35,
        Paint()..color = Colors.white);
  }

  void _starEye(Canvas canvas, double x, double y) {
    const r1 = 6.5;
    const r2 = 3.0;
    const n = 5;
    final path = Path();
    for (int i = 0; i < n * 2; i++) {
      final r = i.isOdd ? r2 : r1;
      final angle = (i * math.pi / n) - math.pi / 2;
      final px = x + r * math.cos(angle);
      final py = y + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD600));
    // Centre dot
    canvas.drawCircle(
        Offset(x, y), 2.5, Paint()..color = const Color(0xFFFF8F00));
  }

  void _drawNoseAndMouth(Canvas canvas) {
    const baseY = _hy + 14.0;
    const w = 10.0;
    final stroke = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (type == CharacterType.cat) {
      // Small triangle nose
      final nosePath = Path()
        ..moveTo(_cx, _hy + 5)
        ..lineTo(_cx - 3.5, _hy + 9)
        ..lineTo(_cx + 3.5, _hy + 9)
        ..close();
      canvas.drawPath(nosePath, Paint()..color = const Color(0xFFEF9A9A));
    } else if (type == CharacterType.dog) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(_cx, _hy + 7), width: 10, height: 7),
        Paint()..color = const Color(0xFF4E342E),
      );
    } else {
      // Human small nose dot
      canvas.drawCircle(Offset(_cx, _hy + 7), 1.8,
          Paint()..color = const Color(0xFFBCAAA4));
    }

    // Mouth
    switch (stage) {
      case 1:
        final p = Path()
          ..moveTo(_cx - w / 2, baseY)
          ..quadraticBezierTo(_cx, baseY + 5, _cx + w / 2, baseY);
        canvas.drawPath(p, stroke);
      case 2:
        canvas.drawLine(
            Offset(_cx - w / 2, baseY + 1),
            Offset(_cx + w / 2, baseY + 1),
            stroke);
      case 3:
        final p = Path()
          ..moveTo(_cx - w / 2, baseY + 2)
          ..quadraticBezierTo(_cx, baseY - 3, _cx + w / 2, baseY + 2);
        canvas.drawPath(p, stroke);
      case 4:
        final p = Path()
          ..moveTo(_cx - w * 0.7, baseY + 1)
          ..quadraticBezierTo(_cx, baseY - 5, _cx + w * 0.7, baseY + 1);
        canvas.drawPath(p, stroke);
      default:
        // Big grin (filled)
        final fill = Path()
          ..moveTo(_cx - w * 0.85, baseY)
          ..quadraticBezierTo(_cx, baseY - 7, _cx + w * 0.85, baseY)
          ..lineTo(_cx + w * 0.85, baseY + 5)
          ..quadraticBezierTo(_cx, baseY, _cx - w * 0.85, baseY + 5)
          ..close();
        canvas.drawPath(fill, Paint()..color = const Color(0xFF212121));
        // Teeth
        canvas.drawRect(
          Rect.fromLTWH(_cx - 5, baseY + 0.5, 10, 4),
          Paint()..color = Colors.white,
        );
    }

    // Dog tongue at stage 3+
    if (type == CharacterType.dog && stage >= 3) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(_cx, baseY + 7), width: 9, height: 11),
        Paint()..color = const Color(0xFFEF9A9A),
      );
    }
  }

  void _drawWhiskers(Canvas canvas) {
    final p = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final xs = [_cx - 28.0, _cx - 12.0];
    final offsets = [-2.0, 2.0, 6.0];
    for (final dy in offsets) {
      canvas.drawLine(
          Offset(xs[0], _hy + 7 + dy), Offset(xs[1], _hy + 8 + dy * 0.4), p);
      canvas.drawLine(Offset(120 - xs[0], _hy + 7 + dy),
          Offset(120 - xs[1], _hy + 8 + dy * 0.4), p);
    }
  }

  void _drawBlush(Canvas canvas) {
    final p = Paint()..color = const Color(0xFFEF9A9A).withValues(alpha: 0.5);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(_cx - 18, _hy + 9), width: 14, height: 8),
        p);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(_cx + 18, _hy + 9), width: 14, height: 8),
        p);
  }

  // ── Animal extras (tail, tongue handled in mouth) ─────────────────────────

  void _drawAnimalExtras(Canvas canvas) {
    final tailPaint = Paint()
      ..color = _skin
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailBase = Offset(_bl + _bw + 2, _bt + _bh * 0.55);

    if (type == CharacterType.cat) {
      final tailPath = Path()
        ..moveTo(tailBase.dx, tailBase.dy)
        ..quadraticBezierTo(tailBase.dx + 22, tailBase.dy - 22,
            tailBase.dx + 18, tailBase.dy - 42);
      canvas.drawPath(tailPath, tailPaint);
    } else if (type == CharacterType.dog) {
      // Wagging tail — angle based on stage
      final angle = (stage >= 4 ? -40.0 : -20.0) * math.pi / 180;
      final end = Offset(tailBase.dx + 22 * math.cos(angle),
          tailBase.dy - 22 * math.sin(angle).abs());
      canvas.drawLine(tailBase, end, tailPaint);
    }
  }

  // ── Accessories ────────────────────────────────────────────────────────────

  void _drawAccessories(Canvas canvas) {
    switch (stage) {
      case 1:
        _drawSweatDrop(canvas);
      case 3:
        _drawSparkle(canvas, _cx + _hr + 8, _hy - _hr - 6, 5);
      case 4:
        _drawSparkle(canvas, _cx + _hr + 10, _hy - _hr - 10, 6);
        _drawSparkle(canvas, _cx - _hr - 8, _hy - _hr - 2, 4);
      case 5:
        _drawCrown(canvas);
        _drawSparkle(canvas, _cx + _hr + 12, _hy - _hr - 14, 7);
        _drawSparkle(canvas, _cx - _hr - 10, _hy - _hr - 8, 5);
      default:
        break;
    }
  }

  void _drawSweatDrop(Canvas canvas) {
    final p = Paint()..color = const Color(0xFF64B5F6).withValues(alpha: 0.9);
    const sx = _cx + _hr + 6;
    const sy = _hy - 8.0;
    final path = Path()
      ..moveTo(sx, sy - 10)
      ..quadraticBezierTo(sx + 5, sy - 2, sx + 5, sy + 2)
      ..quadraticBezierTo(sx + 5, sy + 8, sx, sy + 8)
      ..quadraticBezierTo(sx - 5, sy + 8, sx - 5, sy + 2)
      ..quadraticBezierTo(sx - 5, sy - 2, sx, sy - 10)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawSparkle(Canvas canvas, double x, double y, double r) {
    _drawStar(canvas, x, y, r,
        Paint()..color = const Color(0xFFFFD600).withValues(alpha: 0.85));
  }

  void _drawCrown(Canvas canvas) {
    final fill = Paint()..color = const Color(0xFFFFD600);
    final outline = Paint()
      ..color = const Color(0xFFFF8F00)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final top = _hy - _hr - 15.0;
    final path = Path()
      ..moveTo(_cx - 17, top + 11)
      ..lineTo(_cx - 17, top)
      ..lineTo(_cx - 7, top + 8)
      ..lineTo(_cx, top - 2)
      ..lineTo(_cx + 7, top + 8)
      ..lineTo(_cx + 17, top)
      ..lineTo(_cx + 17, top + 11)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
    // Jewels
    canvas.drawCircle(
        Offset(_cx, top + 2), 3, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(Offset(_cx - 12, top + 5), 2,
        Paint()..color = const Color(0xFF1E88E5));
    canvas.drawCircle(Offset(_cx + 12, top + 5), 2,
        Paint()..color = const Color(0xFF43A047));
  }

  void _drawStar(Canvas canvas, double x, double y, double r, Paint paint) {
    const n = 5;
    final r2 = r / 2.2;
    final path = Path();
    for (int i = 0; i < n * 2; i++) {
      final radius = i.isOdd ? r2 : r;
      final angle = (i * math.pi / n) - math.pi / 2;
      final px = x + radius * math.cos(angle);
      final py = y + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  void _drawRoundRect(Canvas canvas, double x, double y, double w, double h,
      double r, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      paint,
    );
  }

  @override
  bool shouldRepaint(CharacterPainter old) =>
      old.type != type || old.stage != stage;
}
