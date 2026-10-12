import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/streak_calculator.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitState = ref.watch(habitNotifierProvider);
    final streakResult = ref.watch(streakResultProvider);

    // Calculate total perfect days in history
    int perfectDaysCount = 0;
    habitState.logs.forEach((key, log) {
      try {
        final date = AppDateUtils.parseDateKey(key);
        if (StreakCalculator.isDayPerfect(date, habitState.habits, habitState.logs)) {
          perfectDaysCount++;
        }
      } catch (_) {}
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progress & Analytics',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Current Streak',
                    value: '${streakResult.currentStreak} Days',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.streakFlame,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Best Streak Record',
                    value: '${streakResult.bestStreak} Days',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFEAB308),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Perfect Days',
                      value: '$perfectDaysCount Days',
                      icon: Icons.verified_rounded,
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Freezes Used',
                      value: '${streakResult.frozenDateKeys.length}',
                      icon: Icons.ac_unit_rounded,
                      color: AppColors.streakFreeze,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Freezes Held',
                      value:
                          '${streakResult.freezesAvailable}/${StreakCalculator.maxFreezes}',
                      icon: Icons.shield_rounded,
                      color: AppColors.streakFreeze,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Active Habits',
                      value: '${habitState.habits.length}',
                      icon: Icons.task_alt_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Calendar Heatmap Card
            Text(
              'Habit Completion Calendar',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkSurfaceBorder
                      : AppColors.lightSurfaceBorder,
                ),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final isPerfect = StreakCalculator.isDayPerfect(
                      date,
                      habitState.habits,
                      habitState.logs,
                    );
                    final isFrozen = !isPerfect &&
                        streakResult.frozenDateKeys
                            .contains(AppDateUtils.toDateKey(date));
                    if (isPerfect || isFrozen) {
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isPerfect
                                ? AppColors.success
                                : AppColors.streakFreeze,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonTextStyle: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  titleTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkSurfaceBorder
              : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
