import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String appGroupId = 'group.com.nandakishor.smarthabittracker';
  static const String androidWidgetProvider = 'StreakWidgetProvider';

  /// Update native home screen widget payload & trigger UI refresh
  static Future<void> updateStreakWidget({
    required int streakCount,
    required int completedCount,
    required int totalCount,
    required bool isTodayPerfect,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      // Save widget values
      await HomeWidget.saveWidgetData<int>('streak_count', streakCount);
      await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);
      await HomeWidget.saveWidgetData<bool>('is_today_perfect', isTodayPerfect);

      final message = isTodayPerfect
          ? '🎉 All Done Today!'
          : '$completedCount of $totalCount Done Today';
      await HomeWidget.saveWidgetData<String>('widget_message', message);

      // Trigger update on native side
      await HomeWidget.updateWidget(
        androidName: androidWidgetProvider,
        iOSName: 'StreakWidget',
      );
    } catch (e) {
      // Gracefully capture platform errors if running on web or unsupported platform
      debugPrint('Error updating home widget: $e');
    }
  }
}
