import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_calculator.dart';
import 'ember_painter.dart';

/// From this hour on, an unfinished day with a running streak is "at risk".
/// The home-screen widget (StreakWidgetProvider.kt) uses the same rule.
const int emberWorryHour = 18;

/// Picks Ember's mood from today's progress, the streak and the time of day.
EmberMood emberMoodFor(StreakResult streak, DateTime now) {
  if (streak.todayTotalCount == 0) return EmberMood.idle;
  if (streak.isTodayPerfect) return EmberMood.celebrating;

  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final savedYesterday = streak.frozenDateKeys.contains(AppDateUtils.toDateKey(yesterday));
  if (savedYesterday && streak.todayCompletedCount == 0) return EmberMood.frozen;

  if (now.hour >= emberWorryHour && streak.currentStreak > 0) return EmberMood.worried;
  if (streak.todayCompletedCount > 0) return EmberMood.cheering;
  return EmberMood.idle;
}

/// What Ember says for a mood. [variant] picks between lines so tapping Ember
/// gives a fresh message.
String emberMessageFor(EmberMood mood, StreakResult streak, {int variant = 0}) {
  final left = streak.todayTotalCount - streak.todayCompletedCount;
  final done = streak.todayCompletedCount;
  final total = streak.todayTotalCount;
  final days = streak.currentStreak;
  final habitWord = left == 1 ? 'habit' : 'habits';

  final lines = switch (mood) {
    EmberMood.idle => total == 0
        ? [
            "Hi, I'm Ember! Add your first habit and let's light a streak.",
            'Every streak starts with one small habit. Tap + New Habit!',
          ]
        : [
            if (days > 0) 'Your $days-day streak is warm. Let\'s keep it burning!'
            else 'A fresh day! Start with the easiest habit.',
            '$total $habitWord today. Pick one and let\'s go!',
            'Small steps count. Just one habit to get me glowing.',
          ],
    EmberMood.cheering => [
        'Nice! $done of $total done. Keep going!',
        'I\'m heating up! Only $left $habitWord left.',
        'You\'re on a roll. $left more and today is perfect!',
      ],
    EmberMood.worried => [
        'Your $days-day streak is at risk! $left $habitWord left today.',
        if (streak.freezesAvailable > 0)
          'A freeze has your back, but let\'s not need it. $left to go!'
        else
          'No freezes left. Finish $left $habitWord to save the streak!',
        'It\'s getting late… just $left more and we\'re safe.',
      ],
    EmberMood.celebrating => [
        'Perfect day! 🔥 $days-day streak!',
        'All done! You\'re on fire today.',
        if (streak.daysUntilNextFreeze < StreakCalculator.freezeEarnInterval)
          '${streak.daysUntilNextFreeze} more perfect ${streak.daysUntilNextFreeze == 1 ? 'day' : 'days'} for a new freeze ❄️'
        else
          'See you tomorrow. Rest up, champion!',
      ],
    EmberMood.frozen => [
        'Brrr! A freeze saved your streak yesterday. Let\'s warm up today!',
        'Phew, the streak survived on ice. One habit to thaw me out?',
      ],
  };
  return lines[variant % lines.length];
}
