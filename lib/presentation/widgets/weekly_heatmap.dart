import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class WeeklyHeatmap extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool Function(DateTime) isDayPerfect;
  final bool Function(DateTime) isDayFrozen;

  const WeeklyHeatmap({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isDayPerfect,
    required this.isDayFrozen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Generate current week starting 6 days ago up to today
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Consistency',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  _LegendDot(color: AppColors.success, label: 'Perfect', isDark: isDark),
                  const SizedBox(width: 10),
                  _LegendDot(color: AppColors.streakFreeze, label: 'Frozen', isDark: isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final isSelected = day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;
              final perfect = isDayPerfect(day);
              final frozen = !perfect && isDayFrozen(day);
              // Ice blue for frozen days, green for perfect ones.
              final Color? statusColor = perfect
                  ? AppColors.success
                  : (frozen ? AppColors.streakFreeze : null);

              return GestureDetector(
                onTap: () => onDateSelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (statusColor != null
                            ? statusColor.withValues(alpha: 0.2)
                            : (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (statusColor ??
                              (isToday
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : Colors.transparent)),
                      width: isToday || statusColor != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _dayName(day.weekday),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white70
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (statusColor ??
                                  (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        perfect
                            ? Icons.check_circle
                            : (frozen ? Icons.ac_unit_rounded : Icons.circle_outlined),
                        size: 10,
                        color: isSelected
                            ? Colors.white
                            : (statusColor ?? Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendDot({required this.color, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
