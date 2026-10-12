import '../../models/habit.dart';
import '../../models/habit_log.dart';
import 'date_utils.dart';

class StreakResult {
  final int currentStreak;
  final int bestStreak;
  final bool isTodayPerfect;
  final int todayCompletedCount;
  final int todayTotalCount;

  StreakResult({
    required this.currentStreak,
    required this.bestStreak,
    required this.isTodayPerfect,
    required this.todayCompletedCount,
    required this.todayTotalCount,
  });
}

class StreakCalculator {
  /// Evaluates whether a given date was 100% perfectly completed.
  static bool isDayPerfect(
    DateTime date,
    List<Habit> allHabits,
    Map<String, HabitLog> logs,
  ) {
    final dateNorm = AppDateUtils.normalize(date);

    // Active habits on that date (created on or before that date)
    final activeHabits = allHabits.where((h) {
      final habitCreatedNorm = AppDateUtils.normalize(h.createdAt);
      return habitCreatedNorm.isBefore(dateNorm) ||
          habitCreatedNorm.isAtSameMomentAs(dateNorm);
    }).toList();

    if (activeHabits.isEmpty) return false;

    final dateKey = AppDateUtils.toDateKey(dateNorm);
    final log = logs[dateKey];
    if (log == null) return false;

    // Count how many active habits were marked completed
    int completedCount = 0;
    for (var habit in activeHabits) {
      if (log.isHabitCompleted(habit.id)) {
        completedCount++;
      }
    }

    return completedCount == activeHabits.length;
  }

  /// Calculates current streak, best streak, and today's status.
  static StreakResult calculateStreak({
    required DateTime today,
    required List<Habit> habits,
    required Map<String, HabitLog> logs,
  }) {
    final todayNorm = AppDateUtils.normalize(today);
    final todayKey = AppDateUtils.toDateKey(todayNorm);

    // Today's stats
    final activeToday = habits.where((h) {
      final createdNorm = AppDateUtils.normalize(h.createdAt);
      return createdNorm.isBefore(todayNorm) ||
          createdNorm.isAtSameMomentAs(todayNorm);
    }).toList();

    final todayLog = logs[todayKey];
    int todayCompleted = 0;
    if (todayLog != null) {
      for (var h in activeToday) {
        if (todayLog.isHabitCompleted(h.id)) todayCompleted++;
      }
    }

    final isTodayPerfect =
        activeToday.isNotEmpty && (todayCompleted == activeToday.length);

    // --- CURRENT STREAK ---
    int currentStreak = 0;
    DateTime checkDate = todayNorm;

    if (isTodayPerfect) {
      // Today is completed! Count today and walk backwards
      while (isDayPerfect(checkDate, habits, logs)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      // Today is not yet fully completed.
      // Check starting from yesterday. If yesterday was missed, streak is 0!
      checkDate = todayNorm.subtract(const Duration(days: 1));
      while (isDayPerfect(checkDate, habits, logs)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // --- BEST STREAK ---
    int bestStreak = currentStreak;

    // Find earliest habit creation date or earliest log
    DateTime earliest = todayNorm;
    for (var h in habits) {
      final hDate = AppDateUtils.normalize(h.createdAt);
      if (hDate.isBefore(earliest)) earliest = hDate;
    }

    int tempStreak = 0;
    DateTime iter = earliest;
    while (!iter.isAfter(todayNorm)) {
      if (isDayPerfect(iter, habits, logs)) {
        tempStreak++;
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
      } else {
        // Break in streak!
        // Exception: If `iter` is today and it's not finished yet, don't break the best streak record of past days
        if (!AppDateUtils.isSameDay(iter, todayNorm)) {
          tempStreak = 0;
        }
      }
      iter = iter.add(const Duration(days: 1));
    }

    return StreakResult(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      isTodayPerfect: isTodayPerfect,
      todayCompletedCount: todayCompleted,
      todayTotalCount: activeToday.length,
    );
  }
}
