import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/streak_calculator.dart';
import 'ember_mascot.dart';
import 'ember_mood.dart';
import 'ember_painter.dart';

/// Ember with a speech bubble, shown at the top of the Today screen.
class EmberCard extends StatefulWidget {
  final StreakResult streak;

  /// Increments whenever a habit is ticked, so Ember jumps.
  final int reactTick;

  const EmberCard({super.key, required this.streak, this.reactTick = 0});

  @override
  State<EmberCard> createState() => _EmberCardState();
}

class _EmberCardState extends State<EmberCard> {
  int _variant = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mood = emberMoodFor(widget.streak, DateTime.now());
    final message = emberMessageFor(mood, widget.streak, variant: _variant);
    final accent = switch (mood) {
      EmberMood.frozen => AppColors.streakFreeze,
      EmberMood.worried => AppColors.warning,
      EmberMood.celebrating => AppColors.success,
      _ => AppColors.streakFlame,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        EmberMascot(
          mood: mood,
          size: 92,
          reactTick: widget.reactTick,
          onTap: () => setState(() => _variant++),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: CustomPaint(
              painter: _BubbleTailPainter(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: accent.withValues(alpha: 0.45),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.5),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(message),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ember',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: GoogleFonts.inter(fontSize: 13, height: 1.35, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small triangle on the bubble's left edge, pointing at Ember.
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color border;

  _BubbleTailPainter({required this.color, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - 22;
    final tail = Path()
      ..moveTo(1.5, y - 8)
      ..lineTo(-9, y + 2)
      ..lineTo(1.5, y + 8)
      ..close();
    canvas.drawPath(tail, Paint()..color = color);
    canvas.drawPath(
      Path()
        ..moveTo(1, y - 8)
        ..lineTo(-9, y + 2)
        ..lineTo(1, y + 8),
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) => old.color != color || old.border != border;
}
