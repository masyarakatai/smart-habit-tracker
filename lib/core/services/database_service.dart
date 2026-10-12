import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../utils/date_utils.dart';

class DatabaseService {
  static const String habitsBoxName = 'habits_box';
  static const String habitLogsBoxName = 'habit_logs_box';
  static const String settingsBoxName = 'settings_box';

  late Box<Map> _habitsBox;
  late Box<Map> _habitLogsBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _habitsBox = await Hive.openBox<Map>(habitsBoxName);
    _habitLogsBox = await Hive.openBox<Map>(habitLogsBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Reset old demo data so user starts completely fresh starting today
    if (!isFreshStartConfigured()) {
      await resetToFreshStart();
    }
  }

  bool isFreshStartConfigured() {
    return _settingsBox.get('fresh_start_v2', defaultValue: false) as bool;
  }

  /// Resets all data to clean state starting today
  Future<void> resetToFreshStart() async {
    await _habitsBox.clear();
    await _habitLogsBox.clear();
    await _seedFreshHabits();
    await _settingsBox.put('fresh_start_v2', true);
  }

  // --- HABITS CRUD ---

  List<Habit> getAllHabits() {
    return _habitsBox.values
        .map((map) => Habit.fromMap(Map<String, dynamic>.from(map)))
        .where((h) => !h.isArchived)
        .toList();
  }

  Future<void> saveHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit.toMap());
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitsBox.delete(habitId);

    // Remove habitId from all daily logs
    for (var key in _habitLogsBox.keys) {
      final logMap = _habitLogsBox.get(key);
      if (logMap != null) {
        final log = HabitLog.fromMap(Map<String, dynamic>.from(logMap));
        if (log.completedHabitIds.contains(habitId)) {
          final updated = Set<String>.from(log.completedHabitIds)..remove(habitId);
          await _habitLogsBox.put(
            key,
            log.copyWith(completedHabitIds: updated).toMap(),
          );
        }
      }
    }
  }

  // --- DAILY LOGS CRUD ---

  HabitLog getHabitLog(DateTime date) {
    final key = AppDateUtils.toDateKey(date);
    final raw = _habitLogsBox.get(key);
    if (raw != null) {
      return HabitLog.fromMap(Map<String, dynamic>.from(raw));
    }
    return HabitLog(dateKey: key, completedHabitIds: {});
  }

  Map<String, HabitLog> getAllHabitLogs() {
    final Map<String, HabitLog> map = {};
    for (var key in _habitLogsBox.keys) {
      final raw = _habitLogsBox.get(key);
      if (raw != null) {
        final log = HabitLog.fromMap(Map<String, dynamic>.from(raw));
        map[log.dateKey] = log;
      }
    }
    return map;
  }

  Future<void> saveHabitLog(HabitLog log) async {
    await _habitLogsBox.put(log.dateKey, log.toMap());
  }

  Future<void> toggleHabitCompletion(DateTime date, String habitId) async {
    final log = getHabitLog(date);
    final updatedSet = Set<String>.from(log.completedHabitIds);
    if (updatedSet.contains(habitId)) {
      updatedSet.remove(habitId);
    } else {
      updatedSet.add(habitId);
    }
    await saveHabitLog(log.copyWith(completedHabitIds: updatedSet));
  }

  // --- SEED FRESH HABITS STARTING TODAY ---

  Future<void> _seedFreshHabits() async {
    final now = DateTime.now();
    final freshHabits = [
      Habit(
        id: 'fresh_1',
        title: 'Morning Water & Hydration',
        description: 'Drink 500ml of water right after waking up',
        iconCodePoint: 0xe625, // local_drink
        colorValue: 0xFF0EA5E9, // Sky Blue
        createdAt: now,
      ),
      Habit(
        id: 'fresh_2',
        title: '30-Min Daily Exercise',
        description: 'Brisk walk, cardio, or gym workout',
        iconCodePoint: 0xe2bd, // fitness_center
        colorValue: 0xFF10B981, // Emerald Green
        createdAt: now,
      ),
      Habit(
        id: 'fresh_3',
        title: 'Read 15 Pages of a Book',
        description: 'Focus on non-fiction or skill reading',
        iconCodePoint: 0xe3e8, // menu_book
        colorValue: 0xFF8B5CF6, // Purple
        createdAt: now,
      ),
      Habit(
        id: 'fresh_4',
        title: 'Evening Mindful Meditation',
        description: '10 minutes of guided breathing',
        iconCodePoint: 0xe51c, // self_improvement
        colorValue: 0xFFF59E0B, // Amber
        createdAt: now,
      ),
    ];

    for (var habit in freshHabits) {
      await saveHabit(habit);
    }
  }
}
