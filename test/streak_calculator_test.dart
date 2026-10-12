import 'package:flutter_test/flutter_test.dart';
import 'package:habit_track/core/utils/date_utils.dart';
import 'package:habit_track/core/utils/streak_calculator.dart';
import 'package:habit_track/models/habit.dart';
import 'package:habit_track/models/habit_log.dart';

void main() {
  // Fixed "today" so tests don't depend on the real date.
  final today = DateTime(2026, 3, 31, 10);
  DateTime daysAgo(int n) => DateTime(today.year, today.month, today.day - n);

  final habits = [
    Habit(id: 'h1', title: 'Workout', createdAt: daysAgo(40)),
    Habit(id: 'h2', title: 'Meditation', createdAt: daysAgo(40)),
  ];

  /// Builds logs where each entry in [daysAgoToIds] maps a day offset to the
  /// habit ids completed that day.
  Map<String, HabitLog> logsFor(Map<int, Set<String>> daysAgoToIds) {
    return {
      for (final e in daysAgoToIds.entries)
        AppDateUtils.toDateKey(daysAgo(e.key)):
            HabitLog(dateKey: AppDateUtils.toDateKey(daysAgo(e.key)), completedHabitIds: e.value),
    };
  }

  /// All habits completed on days [from]..[to] ago (inclusive, from >= to).
  Map<int, Set<String>> perfectRange(int from, int to) =>
      {for (var d = from; d >= to; d--) d: {'h1', 'h2'}};

  StreakResult calc(Map<String, HabitLog> logs) =>
      StreakCalculator.calculateStreak(today: today, habits: habits, logs: logs);

  group('Strict streak', () {
    test('Counts consecutive perfect past days', () {
      final result = calc(logsFor(perfectRange(2, 1)));

      expect(result.currentStreak, 2);
      expect(result.bestStreak, 2);
      expect(result.isTodayPerfect, isFalse);
    });

    test('Today counts once it is perfect', () {
      final result = calc(logsFor(perfectRange(2, 0)));

      expect(result.currentStreak, 3);
      expect(result.isTodayPerfect, isTrue);
    });

    test('Unfinished today never breaks the streak or uses a freeze', () {
      final result = calc(logsFor({...perfectRange(3, 1), 0: {'h1'}}));

      expect(result.currentStreak, 3);
      expect(result.freezesAvailable, StreakCalculator.initialFreezes);
      expect(result.frozenDateKeys, isEmpty);
    });

    test('Partial completion counts as a missed day', () {
      // Two misses in a row: the starting freeze covers the first only.
      final result = calc(logsFor({3: {'h1', 'h2'}, 2: {'h1'}, 1: {'h2'}}));

      expect(result.currentStreak, 0);
      expect(result.bestStreak, 1);
    });
  });

  group('Streak freeze', () {
    test('Starting freeze protects a single missed day', () {
      // Perfect 4..3 days ago, missed 2 days ago, perfect yesterday.
      final result = calc(logsFor({...perfectRange(4, 3), 1: {'h1', 'h2'}}));

      expect(result.currentStreak, 3); // frozen day keeps but doesn't add
      expect(result.freezesAvailable, 0);
      expect(result.frozenDateKeys, {AppDateUtils.toDateKey(daysAgo(2))});
    });

    test('No freeze is used when there is no streak to protect', () {
      final result = calc(logsFor({1: {'h1', 'h2'}}));

      expect(result.frozenDateKeys, isEmpty);
      expect(result.freezesAvailable, StreakCalculator.initialFreezes);
    });

    test('Earns a freeze every 7 streak days, capped at max', () {
      final result = calc(logsFor(perfectRange(21, 1)));

      expect(result.currentStreak, 21);
      expect(result.freezesAvailable, StreakCalculator.maxFreezes);
      expect(result.daysUntilNextFreeze, 7);
    });

    test('Two held freezes cover two missed days, the third resets', () {
      // 7 perfect days (earns a 2nd freeze), then 3 misses, then 1 perfect.
      final logs = logsFor({...perfectRange(11, 5), 1: {'h1', 'h2'}});
      final result = calc(logs);

      expect(result.frozenDateKeys.length, 2);
      expect(result.currentStreak, 1);
      expect(result.bestStreak, 7);
      expect(result.freezesAvailable, 0);
    });

    test('Days before any habit existed are neutral', () {
      final newHabits = [Habit(id: 'h1', title: 'New', createdAt: daysAgo(1))];
      final result = StreakCalculator.calculateStreak(
        today: today,
        habits: newHabits,
        logs: logsFor({1: {'h1'}}),
      );

      expect(result.currentStreak, 1);
      expect(result.frozenDateKeys, isEmpty);
    });
  });
}
