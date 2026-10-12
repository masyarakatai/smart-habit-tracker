import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../../presentation/widgets/mascot/ember_painter.dart';
import '../utils/date_utils.dart';

class HomeWidgetService {
  static const String appGroupId = 'group.com.nandakishor.smarthabittracker';
  static const String androidWidgetProvider = 'StreakWidgetProvider';

  /// Bump when Ember's artwork changes so widget images are re-rendered.
  static const int emberArtVersion = 1;
  static const int _emberImagePx = 320;

  /// Update native home screen widget payload & trigger UI refresh
  static Future<void> updateStreakWidget({
    required int streakCount,
    required int completedCount,
    required int totalCount,
    required bool isTodayPerfect,
    bool freezeSavedYesterday = false,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      // Save widget values
      await HomeWidget.saveWidgetData<int>('streak_count', streakCount);
      await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);
      await HomeWidget.saveWidgetData<bool>('is_today_perfect', isTodayPerfect);
      await HomeWidget.saveWidgetData<bool>('freeze_saved_yesterday', freezeSavedYesterday);
      // Lets the widget notice a new day even if the app hasn't been opened.
      await HomeWidget.saveWidgetData<String>(
          'data_date', AppDateUtils.toDateKey(DateTime.now()));

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

  /// Renders one still image of Ember per mood for the home-screen widget,
  /// which picks the right one itself (stored under `ember_<mood>`).
  /// Skips the work when the current artwork version is already rendered.
  static Future<void> renderEmberImages({
    required int renderedVersion,
    required Future<void> Function(int version) onRendered,
  }) async {
    if (renderedVersion >= emberArtVersion) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      for (final mood in EmberMood.values) {
        final bytes = await _renderEmber(mood);
        await HomeWidget.saveFile('ember_${mood.name}', bytes, extension: 'png');
      }
      await onRendered(emberArtVersion);
      await HomeWidget.updateWidget(
        androidName: androidWidgetProvider,
        iOSName: 'StreakWidget',
      );
    } catch (e) {
      debugPrint('Error rendering Ember widget images: $e');
    }
  }

  static Future<Uint8List> _renderEmber(EmberMood mood) async {
    const size = _emberImagePx;
    final recorder = ui.PictureRecorder();
    // A representative "pose" for each mood (eyes looking slightly down at you).
    EmberPainter(mood: mood, t: 0.25, look: const Offset(0, 0.35))
        .paint(Canvas(recorder), const Size(size + 0.0, size + 0.0));
    final image = await recorder.endRecording().toImage(size, size);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }
}
