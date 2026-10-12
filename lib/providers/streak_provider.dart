import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/home_widget_service.dart';
import '../core/utils/streak_calculator.dart';
import 'habit_provider.dart';

final streakResultProvider = Provider<StreakResult>((ref) {
  final habitState = ref.watch(habitNotifierProvider);

  final result = StreakCalculator.calculateStreak(
    today: DateTime.now(),
    habits: habitState.habits,
    logs: habitState.logs,
  );

  // Sync latest streak data to Home Screen Native Widget
  HomeWidgetService.updateStreakWidget(
    streakCount: result.currentStreak,
    completedCount: result.todayCompletedCount,
    totalCount: result.todayTotalCount,
    isTodayPerfect: result.isTodayPerfect,
  );

  return result;
});
