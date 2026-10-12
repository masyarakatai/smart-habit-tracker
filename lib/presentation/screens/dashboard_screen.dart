import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/streak_calculator.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/add_edit_habit_dialog.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/habit_tile.dart';
import '../widgets/streak_badge.dart';
import '../widgets/weekly_heatmap.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _openAddHabitDialog(BuildContext context, WidgetRef ref) async {
    final habit = await AddEditHabitDialog.show(context);
    if (habit != null) {
      ref.read(habitNotifierProvider.notifier).addHabit(habit);
    }
  }

  void _openEditHabitDialog(
      BuildContext context, WidgetRef ref, Habit habit) async {
    final updated = await AddEditHabitDialog.show(context, habit: habit);
    if (updated != null) {
      ref.read(habitNotifierProvider.notifier).updateHabit(updated);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitState = ref.watch(habitNotifierProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final streakResult = ref.watch(streakResultProvider);

    final selectedDateNorm = AppDateUtils.normalize(selectedDate);
    final selectedKey = AppDateUtils.toDateKey(selectedDateNorm);
    final currentLog = habitState.logs[selectedKey];

    // Filter active habits created on or before selectedDate
    final activeHabits = habitState.habits.where((h) {
      final hDate = AppDateUtils.normalize(h.createdAt);
      return hDate.isBefore(selectedDateNorm) ||
          hDate.isAtSameMomentAs(selectedDateNorm);
    }).toList();

    final completedCount = activeHabits
        .where((h) => currentLog?.isHabitCompleted(h.id) ?? false)
        .length;

    final progressRatio = activeHabits.isEmpty
        ? 0.0
        : (completedCount / activeHabits.length).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_box_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Habit Track',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Analytics',
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Start Fresh Today',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  content: Text(
                      'Reset all past history and start fresh from today?',
                      style: GoogleFonts.inter()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                      child: const Text('Start Fresh'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(habitNotifierProvider.notifier).resetFreshStart();
              }
            },
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Start Fresh Today',
          ),
          IconButton(
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: habitState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(habitNotifierProvider.notifier).loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Badge Banner
                    StreakBadge(streakCount: streakResult.currentStreak),

                    const SizedBox(height: 16),

                    // Weekly Progress Heatmap Bar
                    WeeklyHeatmap(
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        ref.read(selectedDateProvider.notifier).selectDate(date);
                      },
                      isDayPerfect: (date) {
                        return StreakCalculator.isDayPerfect(
                          date,
                          habitState.habits,
                          habitState.logs,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Selected Date Header & Completion Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppDateUtils.isSameDay(selectedDate, DateTime.now())
                                  ? 'Today\'s Habits'
                                  : AppDateUtils.formatHeaderDate(selectedDate),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeHabits.isEmpty
                                  ? 'No active habits defined'
                                  : '$completedCount of ${activeHabits.length} completed',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (activeHabits.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: progressRatio == 1.0
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(progressRatio * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: progressRatio == 1.0
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Animated Progress Line
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceBorder
                            : AppColors.lightSurfaceBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressRatio == 1.0
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Habit Checklist List
                    if (activeHabits.isEmpty)
                      _EmptyStateView(
                        onAddTap: () => _openAddHabitDialog(context, ref),
                        isDark: isDark,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeHabits.length,
                        itemBuilder: (context, index) {
                          final habit = activeHabits[index];
                          final isDone = currentLog?.isHabitCompleted(habit.id) ?? false;

                          return HabitTile(
                            habit: habit,
                            isCompleted: isDone,
                            onToggle: () async {
                              final isNowPerfect = await ref
                                  .read(habitNotifierProvider.notifier)
                                  .toggleHabitCompletion(
                                      selectedDate, habit.id);

                              // If toggling on today achieved 100% daily completeness, show celebration dialog!
                              if (!isDone &&
                                  isNowPerfect &&
                                  AppDateUtils.isSameDay(
                                      selectedDate, DateTime.now())) {
                                final updatedStreak = ref
                                    .read(streakResultProvider)
                                    .currentStreak;
                                CelebrationOverlay.show(
                                    context, updatedStreak);
                              }
                            },
                            onEdit: () =>
                                _openEditHabitDialog(context, ref, habit),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Delete Habit', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  content: Text('Are you sure you want to delete "${habit.title}"?', style: GoogleFonts.inter()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
                              }
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddHabitDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Habit',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final VoidCallback onAddTap;
  final bool isDark;

  const _EmptyStateView({required this.onAddTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkSurfaceBorder
              : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_task_rounded,
            size: 56,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Habits Found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start your daily streak by creating your first habit.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Habit'),
          ),
        ],
      ),
    );
  }
}
