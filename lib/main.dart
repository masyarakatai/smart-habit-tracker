import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/database_service.dart';
import 'core/services/home_widget_service.dart';
import 'providers/habit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  await dbService.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const HabitTrackApp(),
    ),
  );

  // Draw Ember's mood images for the home-screen widget (once per art version).
  HomeWidgetService.renderEmberImages(
    renderedVersion: (dbService.getSetting('ember_art_version') as int?) ?? 0,
    onRendered: (v) => dbService.putSetting('ember_art_version', v),
  );
}
