import '../../models/habit.dart';
import '../../models/habit_log.dart';
import 'date_utils.dart';

class StreakResult {
  final int currentStreak;
  final int bestStreak;
  final bool isTodayPerfect;
  final int todayCompletedCount;
  final int todayTotalCount;

  /// Streak freezes currently held (0..[StreakCalculator.maxFreezes]).
  final int freezesAvailable;

  /// Date keys ("YYYY-MM-DD") of missed days that a freeze protected.
  final Set<String> frozenDateKeys;

  /// Perfect days still needed to earn the next freeze.
  final int daysUntilNextFreeze;

  StreakResult({
    required this.currentStreak,
    required this.bestStreak,
    required this.isTodayPerfect,
    required this.todayCompletedCount,
    required this.todayTotalCount,
    this.freezesAvailable = 0,
    this.frozenDateKeys = const {},
    this.daysUntilNextFreeze = StreakCalculator.freezeEarnInterval,
  });
}

class StreakCalculator {
  /// Freezes held at the very start, so a new streak has a safety net.
  static const int initialFreezes = 1;

  /// Maximum freezes that can be held at once (like Duolingo's 2).
  static const int maxFreezes = 2;

  /// A freeze is earned every time the streak reaches a multiple of this.
  static const int freezeEarnInterval = 7;

  static List<Habit> _activeOn(DateTime dateNorm, List<Habit> allHabits) {
    return allHabits.where((h) {
      final habitCreatedNorm = AppDateUtils.normalize(h.createdAt);
      return !habitCreatedNorm.isAfter(dateNorm);
    }).toList();
  }

  /// Evaluates whether a given date was 100% perfectly completed.
  static bool isDayPerfect(
    DateTime date,
    List<Habit> allHabits,
    Map<String, HabitLog> logs,
  ) {
    final dateNorm = AppDateUtils.normalize(date);

    // Active habits on that date (created on or before that date)
    final activeHabits = _activeOn(dateNorm, allHabits);
    if (activeHabits.isEmpty) return false;

    final log = logs[AppDateUtils.toDateKey(dateNorm)];
    if (log == null) return false;

    return activeHabits.every((habit) => log.isHabitCompleted(habit.id));
  }

  /// Calculates current streak, best streak, today's status and freezes.
  ///
  /// Walks every day from the first habit's creation up to [today]:
  /// - Perfect day: streak +1. Every [freezeEarnInterval] streak days earns a
  ///   freeze (up to [maxFreezes]).
  /// - Missed past day: if a streak is running and a freeze is held, the freeze
  ///   is used and the streak is kept (but not increased). Otherwise the
  ///   streak resets to 0.
  /// - Today never breaks the streak: it is still in progress.
  /// - Days with no active habits are neutral.
  static StreakResult calculateStreak({
    required DateTime today,
    required List<Habit> habits,
    required Map<String, HabitLog> logs,
  }) {
    final todayNorm = AppDateUtils.normalize(today);
    final todayKey = AppDateUtils.toDateKey(todayNorm);

    // Today's stats
    final activeToday = _activeOn(todayNorm, habits);
    final todayLog = logs[todayKey];
    final todayCompleted = todayLog == null
        ? 0
        : activeToday.where((h) => todayLog.isHabitCompleted(h.id)).length;
    final isTodayPerfect =
        activeToday.isNotEmpty && (todayCompleted == activeToday.length);

    // Find earliest habit creation date
    DateTime earliest = todayNorm;
    for (var h in habits) {
      final hDate = AppDateUtils.normalize(h.createdAt);
      if (hDate.isBefore(earliest)) earliest = hDate;
    }

    int streak = 0;
    int bestStreak = 0;
    int freezes = initialFreezes;
    final frozen = <String>{};

    void addPerfectDay() {
      streak++;
      if (streak > bestStreak) bestStreak = streak;
      if (streak % freezeEarnInterval == 0 && freezes < maxFreezes) {
        freezes++;
      }
    }

    DateTime iter = earliest;
    while (iter.isBefore(todayNorm)) {
      if (_activeOn(iter, habits).isNotEmpty) {
        if (isDayPerfect(iter, habits, logs)) {
          addPerfectDay();
        } else if (streak > 0 && freezes > 0) {
          freezes--;
          frozen.add(AppDateUtils.toDateKey(iter));
        } else {
          streak = 0;
        }
      }
      // Calendar-day step (safe across DST changes)
      iter = DateTime(iter.year, iter.month, iter.day + 1);
    }

    if (isTodayPerfect) addPerfectDay();

    return StreakResult(
      currentStreak: streak,
      bestStreak: bestStreak,
      isTodayPerfect: isTodayPerfect,
      todayCompletedCount: todayCompleted,
      todayTotalCount: activeToday.length,
      freezesAvailable: freezes,
      frozenDateKeys: frozen,
      daysUntilNextFreeze:
          freezeEarnInterval - (streak % freezeEarnInterval),
    );
  }
}
