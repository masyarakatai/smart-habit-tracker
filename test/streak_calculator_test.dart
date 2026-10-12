import 'package:flutter_test/flutter_test.dart';
import 'package:habit_track/core/utils/date_utils.dart';
import 'package:habit_track/core/utils/streak_calculator.dart';
import 'package:habit_track/models/habit.dart';
import 'package:habit_track/models/habit_log.dart';

void main() {
  group('StreakCalculator Unit Tests', () {
    final now = DateTime.now();

    final habit1 = Habit(
      id: 'h1',
      title: 'Workout',
      createdAt: now.subtract(const Duration(days: 10)),
    );
    final habit2 = Habit(
      id: 'h2',
      title: 'Meditation',
      createdAt: now.subtract(const Duration(days: 10)),
    );

    final habits = [habit1, habit2];

    test('Strict Streak: Increments when all daily habits completed', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final dayBefore = now.subtract(const Duration(days: 2));

      final logs = {
        AppDateUtils.toDateKey(dayBefore):
            HabitLog(dateKey: AppDateUtils.toDateKey(dayBefore), completedHabitIds: {'h1', 'h2'}),
        AppDateUtils.toDateKey(yesterday):
            HabitLog(dateKey: AppDateUtils.toDateKey(yesterday), completedHabitIds: {'h1', 'h2'}),
      };

      final result = StreakCalculator.calculateStreak(
        today: now,
        habits: habits,
        logs: logs,
      );

      // Yesterday and day before were 100% complete => streak is 2
      expect(result.currentStreak, equals(2));
      expect(result.bestStreak, equals(2));
      expect(result.isTodayPerfect, isFalse);
    });

    test('Strict Streak: Resets to 0 if a past day was missed', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final dayBefore = now.subtract(const Duration(days: 2));

      final logs = {
        AppDateUtils.toDateKey(dayBefore):
            HabitLog(dateKey: AppDateUtils.toDateKey(dayBefore), completedHabitIds: {'h1', 'h2'}),
        // Yesterday only completed 1 of 2 habits => MISSED
        AppDateUtils.toDateKey(yesterday):
            HabitLog(dateKey: AppDateUtils.toDateKey(yesterday), completedHabitIds: {'h1'}),
      };

      final result = StreakCalculator.calculateStreak(
        today: now,
        habits: habits,
        logs: logs,
      );

      // Yesterday missed => streak resets to 0!
      expect(result.currentStreak, equals(0));
      expect(result.bestStreak, equals(1)); // Day before was 1
    });
  });
}
