import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class StreakBadge extends StatelessWidget {
  final int streakCount;
  final bool isCompact;
  final int freezesAvailable;
  final int maxFreezes;
  final int daysUntilNextFreeze;

  const StreakBadge({
    super.key,
    required this.streakCount,
    this.isCompact = false,
    this.freezesAvailable = 0,
    this.maxFreezes = 2,
    this.daysUntilNextFreeze = 7,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.streakFlame.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.streakFlame.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.streakFlame,
                  size: 18,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 800.ms,
                ),
            const SizedBox(width: 4),
            Text(
              '$streakCount',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.streakFlame,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [Colors.white, const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              streakCount > 0
                  ? AppColors.streakFlame.withValues(alpha: 0.3)
                  : (isDark
                      ? AppColors.darkSurfaceBorder
                      : AppColors.lightSurfaceBorder),
          width: 1.5,
        ),
        boxShadow: [
          if (streakCount > 0)
            BoxShadow(
              color: AppColors.streakFlame.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  streakCount > 0
                      ? AppColors.streakFlame.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
                  Icons.local_fire_department_rounded,
                  color: streakCount > 0 ? AppColors.streakFlame : Colors.grey,
                  size: 28,
                )
                .animate(target: streakCount > 0 ? 1 : 0)
                .shake(duration: 600.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 800.ms,
                ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$streakCount',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color:
                            streakCount > 0
                                ? AppColors.streakFlame
                                : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      streakCount == 1 ? 'DAY STREAK' : 'DAYS STREAK',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color:
                            streakCount > 0
                                ? AppColors.streakFlame
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  streakCount > 0
                      ? '100% Perfect Days Active 🔥'
                      : 'Complete today to build streak',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  freezesAvailable >= maxFreezes
                      ? 'Freezes full ❄️'
                      : 'Next freeze in $daysUntilNextFreeze perfect '
                          '${daysUntilNextFreeze == 1 ? 'day' : 'days'}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.streakFreeze,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FreezeCounter(
            freezesAvailable: freezesAvailable,
            maxFreezes: maxFreezes,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// Shows held streak freezes as ice-blue snowflakes (empty slots are dimmed).
class _FreezeCounter extends StatelessWidget {
  final int freezesAvailable;
  final int maxFreezes;
  final bool isDark;

  const _FreezeCounter({
    required this.freezesAvailable,
    required this.maxFreezes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          'Streak freezes protect your streak if you miss a day. '
          'Earn one every 7 perfect days.',
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.streakFreeze.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.streakFreeze.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(maxFreezes, (i) {
                final held = i < freezesAvailable;
                return Icon(
                  Icons.ac_unit_rounded,
                  size: 18,
                  color:
                      held
                          ? AppColors.streakFreeze
                          : (isDark ? Colors.white24 : Colors.black26),
                );
              }),
            ),
            const SizedBox(height: 2),
            Text(
              '$freezesAvailable/$maxFreezes',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.streakFreeze,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
