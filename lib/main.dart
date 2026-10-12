import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/database_service.dart';
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
}
