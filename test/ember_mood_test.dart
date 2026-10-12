import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_track/core/utils/date_utils.dart';
import 'package:habit_track/core/utils/streak_calculator.dart';
import 'package:habit_track/presentation/widgets/mascot/ember_mascot.dart';
import 'package:habit_track/presentation/widgets/mascot/ember_mood.dart';
import 'package:habit_track/presentation/widgets/mascot/ember_painter.dart';

StreakResult result({
  int streak = 3,
  int done = 0,
  int total = 2,
  Set<String> frozen = const {},
  int freezes = 1,
}) =>
    StreakResult(
      currentStreak: streak,
      bestStreak: streak,
      isTodayPerfect: total > 0 && done == total,
      todayCompletedCount: done,
      todayTotalCount: total,
      freezesAvailable: freezes,
      frozenDateKeys: frozen,
      daysUntilNextFreeze: 4,
    );

void main() {
  final morning = DateTime(2026, 3, 31, 9);
  final evening = DateTime(2026, 3, 31, 20);
  final yesterdayKey = AppDateUtils.toDateKey(DateTime(2026, 3, 30));

  group('emberMoodFor', () {
    test('No habits: idle', () {
      expect(emberMoodFor(result(total: 0), evening), EmberMood.idle);
    });

    test('Nothing done in the morning: idle', () {
      expect(emberMoodFor(result(), morning), EmberMood.idle);
    });

    test('Some done: cheering', () {
      expect(emberMoodFor(result(done: 1), morning), EmberMood.cheering);
    });

    test('All done: celebrating, even late', () {
      expect(emberMoodFor(result(done: 2), evening), EmberMood.celebrating);
    });

    test('Evening, unfinished, streak running: worried', () {
      expect(emberMoodFor(result(done: 1), evening), EmberMood.worried);
    });

    test('Evening without a streak is not worried', () {
      expect(emberMoodFor(result(streak: 0), evening), EmberMood.idle);
    });

    test('Freeze used yesterday and nothing done yet: frozen', () {
      final r = result(frozen: {yesterdayKey});
      expect(emberMoodFor(r, morning), EmberMood.frozen);
      // Once you start, Ember thaws out.
      expect(emberMoodFor(result(done: 1, frozen: {yesterdayKey}), morning), EmberMood.cheering);
    });
  });

  group('emberMessageFor', () {
    test('Variants cycle and mention real numbers', () {
      final r = result(done: 1);
      final a = emberMessageFor(EmberMood.cheering, r, variant: 0);
      final b = emberMessageFor(EmberMood.cheering, r, variant: 1);
      expect(a, contains('1 of 2'));
      expect(a, isNot(b));
      expect(emberMessageFor(EmberMood.cheering, r, variant: 3), a);
    });

    test('Worried message reflects whether a freeze is held', () {
      expect(emberMessageFor(EmberMood.worried, result(freezes: 0), variant: 1), contains('No freezes'));
      expect(emberMessageFor(EmberMood.worried, result(freezes: 1), variant: 1), contains('freeze has your back'));
    });
  });

  testWidgets('EmberMascot animates and jumps on tap without errors', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Center(child: EmberMascot(mood: EmberMood.cheering, onTap: () => taps++)),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(EmberMascot));
    await tester.pump(const Duration(milliseconds: 300));
    expect(taps, 1);

    // Mood change while animating.
    await tester.pumpWidget(const MaterialApp(home: Center(child: EmberMascot(mood: EmberMood.frozen))));
    await tester.pump(const Duration(seconds: 1));
    // Let the blink/glance timers fire, then tear down cleanly.
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpWidget(const SizedBox());
  });
}
