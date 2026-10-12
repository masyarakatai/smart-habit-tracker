import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ember's moods, from calm to excited.
enum EmberMood {
  /// Nothing done yet today. Calm, blinking, gently swaying.
  idle,

  /// Some habits done. Bouncy and waving.
  cheering,

  /// Evening and the streak is at risk. Droopy, sweating.
  worried,

  /// Every habit done today. Jumping with sparkles.
  celebrating,

  /// A freeze saved the streak. Icy blue and shivering.
  frozen,
}

/// Draws Ember, the flame mascot, inside a square canvas.
///
/// All animation comes in as plain numbers, so the same painter is used for
/// the live in-app mascot and for the still home-screen widget images.
class EmberPainter extends CustomPainter {
  final EmberMood mood;

  /// Ambient loop progress, 0..1 (sway, bounce, flicker).
  final double t;

  /// 0 = eyes open, 1 = fully closed.
  final double blink;

  /// Where the eyes look, each axis -1..1.
  final Offset look;

  /// Extra jump from a tap or a ticked habit, 0..1 (peaks at 0.5).
  final double react;

  const EmberPainter({
    required this.mood,
    this.t = 0,
    this.blink = 0,
    this.look = Offset.zero,
    this.react = 0,
  });

  static const _flameColors = [Color(0xFFFEF3C7), Color(0xFFFB923C), Color(0xFFEA580C)];
  static const _iceColors = [Color(0xFFF0F9FF), Color(0xFF7DD3FC), Color(0xFF0284C7)];
  static const _ink = Color(0xFF3B1A0B);
  static const _iceInk = Color(0xFF0C4A6E);

  bool get _frozen => mood == EmberMood.frozen;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw at 84% size, anchored to the bottom, so jumps have headroom.
    const fit = 0.84;
    canvas.save();
    canvas.translate(size.width * (1 - fit) / 2, size.height * (1 - fit));
    _paintScaled(canvas, size.shortestSide * fit);
    canvas.restore();
  }

  void _paintScaled(Canvas canvas, double s) {
    final wave = math.sin(t * 2 * math.pi);
    final fast = math.sin(t * 4 * math.pi);

    // Body motion per mood (fractions of the canvas).
    double bounce, sway, shiver = 0, squash = 1;
    switch (mood) {
      case EmberMood.idle:
        bounce = 0.012 * (1 + wave);
        sway = 0.035 * wave;
      case EmberMood.cheering:
        bounce = 0.03 * (1 + fast);
        sway = 0.05 * wave;
      case EmberMood.worried:
        bounce = 0.005 * (1 + wave);
        sway = 0.02 * wave;
        squash = 0.94;
      case EmberMood.celebrating:
        bounce = 0.07 * fast.abs();
        sway = 0.06 * wave;
      case EmberMood.frozen:
        bounce = 0;
        sway = 0;
        shiver = 0.008 * math.sin(t * 24 * math.pi);
        squash = 0.97;
    }
    final jump = math.sin(react.clamp(0.0, 1.0) * math.pi) * 0.12;
    final lift = (bounce + jump) * s;

    // Ground shadow shrinks as Ember goes up.
    final shadowScale = 1 - (bounce + jump) * 3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.955),
        width: s * 0.5 * shadowScale,
        height: s * 0.06 * shadowScale,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    canvas.save();
    // Pivot at the bottom centre so sway and squash look natural.
    canvas.translate(s * (0.5 + shiver), s * 0.94 - lift);
    canvas.rotate(sway * 0.5);
    canvas.scale(1 / math.sqrt(squash), squash);
    canvas.translate(-s * 0.5, -s * 0.94);

    _drawArms(canvas, s, wave, fast);
    _drawBody(canvas, s, wave);
    _drawFace(canvas, s);
    canvas.restore();

    if (mood == EmberMood.celebrating) _drawSparkles(canvas, s);
    if (mood == EmberMood.worried) _drawSweat(canvas, s, wave);
    if (_frozen) _drawIce(canvas, s);
  }

  Path _flamePath(double s, double flicker) {
    Offset p(double x, double y) => Offset(x * s, y * s);
    final tip = p(0.5 + flicker * 0.035, 0.08);
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(p(0.62, 0.24).dx, p(0.62, 0.24).dy, p(0.84, 0.38).dx,
          p(0.84, 0.38).dy, p(0.84, 0.64).dx, p(0.84, 0.64).dy)
      ..cubicTo(p(0.84, 0.84).dx, p(0.84, 0.84).dy, p(0.69, 0.94).dx,
          p(0.69, 0.94).dy, p(0.5, 0.94).dx, p(0.5, 0.94).dy)
      ..cubicTo(p(0.31, 0.94).dx, p(0.31, 0.94).dy, p(0.16, 0.84).dx,
          p(0.16, 0.84).dy, p(0.16, 0.64).dx, p(0.16, 0.64).dy)
      ..cubicTo(p(0.16, 0.48).dx, p(0.16, 0.48).dy, p(0.25, 0.39).dx,
          p(0.25, 0.39).dy, p(0.34, 0.31).dx, p(0.34, 0.31).dy)
      ..cubicTo(p(0.35, 0.40).dx, p(0.35, 0.40).dy, p(0.40, 0.45).dx,
          p(0.40, 0.45).dy, p(0.46, 0.47).dx, p(0.46, 0.47).dy)
      ..cubicTo(p(0.42, 0.34).dx, p(0.42, 0.34).dy, p(0.44 + flicker * 0.02, 0.19).dx,
          p(0.44, 0.19).dy, tip.dx, tip.dy)
      ..close();
  }

  void _drawBody(Canvas canvas, double s, double wave) {
    final colors = _frozen ? _iceColors : _flameColors;
    final body = _flamePath(s, _frozen ? 0 : wave);
    final rect = Rect.fromLTWH(0, s * 0.08, s, s * 0.86);

    // Soft glow behind the flame.
    if (!_frozen) {
      canvas.drawPath(
        body,
        Paint()
          ..color = const Color(0xFFF97316).withValues(alpha: mood == EmberMood.worried ? 0.15 : 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.05),
      );
    }

    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );

    // Soft inner light low on the belly (kept below the mouth).
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s * 0.5, s * 0.86), width: s * 0.3, height: s * 0.1),
      Paint()
        ..color = Colors.white.withValues(alpha: _frozen ? 0.3 : 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02),
    );
  }

  void _drawArms(Canvas canvas, double s, double wave, double fast) {
    final paint = Paint()
      ..color = _frozen ? const Color(0xFF38BDF8) : const Color(0xFFF97316)
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Arm angle in radians from pointing straight down, per side.
    double left, right;
    switch (mood) {
      case EmberMood.idle:
        left = 0.5;
        right = 0.5;
      case EmberMood.cheering:
        left = 0.6;
        right = 2.2 + 0.5 * fast; // waving
      case EmberMood.worried:
        left = 0.25;
        right = 0.25;
      case EmberMood.celebrating:
        left = 2.6 + 0.3 * fast; // both up
        right = 2.6 - 0.3 * fast;
      case EmberMood.frozen:
        left = 1.2; // hugging itself
        right = 1.2;
    }
    final len = s * 0.15;
    for (final side in [-1.0, 1.0]) {
      final angle = side < 0 ? left : right;
      final shoulder = Offset(s * (0.5 + side * 0.31), s * 0.7);
      final hand = shoulder + Offset(side * math.sin(angle) * len, math.cos(angle) * len);
      canvas.drawLine(shoulder, hand, paint);
    }
  }

  void _drawFace(Canvas canvas, double s) {
    final ink = _frozen ? _iceInk : _ink;
    final eyeY = s * 0.6;
    final happyEyes = mood == EmberMood.celebrating;

    for (final x in [0.4, 0.6]) {
      final c = Offset(s * x, eyeY);
      if (happyEyes) {
        // ^ ^ eyes
        final path = Path()
          ..moveTo(c.dx - s * 0.05, c.dy + s * 0.015)
          ..quadraticBezierTo(c.dx, c.dy - s * 0.055, c.dx + s * 0.05, c.dy + s * 0.015);
        canvas.drawPath(
          path,
          Paint()
            ..color = ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.028
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      final open = (1 - blink).clamp(0.08, 1.0);
      final eyeRect = Rect.fromCenter(center: c, width: s * 0.13, height: s * 0.16 * open);
      canvas.drawOval(eyeRect, Paint()..color = Colors.white);
      if (open > 0.3) {
        final pupil = c + Offset(look.dx * s * 0.025, look.dy * s * 0.025 + s * 0.01);
        canvas.drawCircle(pupil, s * 0.042, Paint()..color = ink);
        canvas.drawCircle(pupil + Offset(-s * 0.014, -s * 0.016), s * 0.013,
            Paint()..color = Colors.white);
      }
    }

    // Brows only when worried.
    if (mood == EmberMood.worried) {
      final brow = Paint()
        ..color = ink
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(s * 0.35, s * 0.5), Offset(s * 0.44, s * 0.47), brow);
      canvas.drawLine(Offset(s * 0.65, s * 0.5), Offset(s * 0.56, s * 0.47), brow);
    }

    // Blush
    if (!_frozen) {
      final blush = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.28);
      canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.31, s * 0.7), width: s * 0.09, height: s * 0.05), blush);
      canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.69, s * 0.7), width: s * 0.09, height: s * 0.05), blush);
    }

    // Mouth
    final mouth = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.024
      ..strokeCap = StrokeCap.round;
    final m = Offset(s * 0.5, s * 0.74);
    switch (mood) {
      case EmberMood.idle:
      case EmberMood.cheering:
        final w = mood == EmberMood.cheering ? 0.075 : 0.055;
        canvas.drawPath(
          Path()
            ..moveTo(m.dx - s * w, m.dy)
            ..quadraticBezierTo(m.dx, m.dy + s * w * 0.9, m.dx + s * w, m.dy),
          mouth,
        );
      case EmberMood.celebrating:
        final open = Path()
          ..moveTo(m.dx - s * 0.08, m.dy - s * 0.01)
          ..quadraticBezierTo(m.dx, m.dy + s * 0.12, m.dx + s * 0.08, m.dy - s * 0.01)
          ..close();
        canvas.drawPath(open, Paint()..color = ink);
        canvas.save();
        canvas.clipPath(open);
        canvas.drawCircle(Offset(m.dx, m.dy + s * 0.07), s * 0.04,
            Paint()..color = const Color(0xFFF43F5E));
        canvas.restore();
      case EmberMood.worried:
        canvas.drawPath(
          Path()
            ..moveTo(m.dx - s * 0.045, m.dy + s * 0.025)
            ..quadraticBezierTo(m.dx, m.dy - s * 0.02, m.dx + s * 0.045, m.dy + s * 0.025),
          mouth,
        );
      case EmberMood.frozen:
        // chattering teeth zigzag
        final z = Path()..moveTo(m.dx - s * 0.07, m.dy);
        for (var i = 1; i <= 6; i++) {
          z.lineTo(m.dx - s * 0.07 + i * s * 0.0233, m.dy + (i.isOdd ? s * 0.025 : 0));
        }
        canvas.drawPath(z, mouth..strokeWidth = s * 0.018);
    }
  }

  void _drawSparkles(Canvas canvas, double s) {
    final paint = Paint()..color = const Color(0xFFFBBF24);
    const spots = [
      (0.14, 0.2, 0.0),
      (0.86, 0.16, 0.33),
      (0.9, 0.52, 0.66),
      (0.1, 0.55, 0.5),
    ];
    for (final (x, y, phase) in spots) {
      final k = (math.sin((t + phase) * 2 * math.pi) + 1) / 2; // twinkle 0..1
      final r = s * (0.025 + 0.025 * k);
      final c = Offset(s * x, s * y);
      final star = Path()
        ..moveTo(c.dx, c.dy - r * 1.6)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 1.6, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 1.6)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 1.6, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 1.6);
      canvas.drawPath(star, paint..color = paint.color.withValues(alpha: 0.5 + 0.5 * k));
    }
  }

  void _drawSweat(Canvas canvas, double s, double wave) {
    final c = Offset(s * 0.78, s * (0.42 + 0.02 * wave));
    final r = s * 0.035;
    final drop = Path()
      ..moveTo(c.dx, c.dy - r * 2)
      ..quadraticBezierTo(c.dx + r * 1.2, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 1.2, c.dy, c.dx, c.dy - r * 2);
    canvas.drawPath(drop, Paint()..color = const Color(0xFF38BDF8));
  }

  void _drawIce(Canvas canvas, double s) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = s * 0.012
      ..strokeCap = StrokeCap.round;
    for (final (x, y, r) in [(0.18, 0.28, 0.045), (0.84, 0.3, 0.035), (0.88, 0.74, 0.03)]) {
      final c = Offset(s * x, s * y);
      for (var i = 0; i < 3; i++) {
        final a = i * math.pi / 3;
        final d = Offset(math.cos(a), math.sin(a)) * (s * r);
        canvas.drawLine(c - d, c + d, paint);
      }
    }
  }

  @override
  bool shouldRepaint(EmberPainter old) =>
      old.mood != mood || old.t != t || old.blink != blink || old.look != look || old.react != react;
}
