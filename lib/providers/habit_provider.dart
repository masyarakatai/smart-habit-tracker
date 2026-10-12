import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/database_service.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../core/utils/date_utils.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('DatabaseService must be initialized in main()');
});

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }
}

/// Provider for the currently selected date on the Dashboard
final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class HabitState {
  final List<Habit> habits;
  final Map<String, HabitLog> logs;
  final bool isLoading;

  HabitState({
    required this.habits,
    required this.logs,
    this.isLoading = false,
  });

  HabitState copyWith({
    List<Habit>? habits,
    Map<String, HabitLog>? logs,
    bool? isLoading,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HabitNotifier extends Notifier<HabitState> {
  @override
  HabitState build() {
    final dbService = ref.watch(databaseServiceProvider);
    final habits = dbService.getAllHabits();
    final logs = dbService.getAllHabitLogs();
    return HabitState(habits: habits, logs: logs, isLoading: false);
  }

  void loadData() {
    final dbService = ref.read(databaseServiceProvider);
    final habits = dbService.getAllHabits();
    final logs = dbService.getAllHabitLogs();
    state = HabitState(habits: habits, logs: logs, isLoading: false);
  }

  Future<void> addHabit(Habit habit) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.saveHabit(habit);
    loadData();
  }

  Future<void> updateHabit(Habit habit) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.saveHabit(habit);
    loadData();
  }

  Future<void> deleteHabit(String habitId) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.deleteHabit(habitId);
    loadData();
  }

  Future<void> resetFreshStart() async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.resetToFreshStart();
    loadData();
  }

  Future<bool> toggleHabitCompletion(DateTime date, String habitId) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.toggleHabitCompletion(date, habitId);
    loadData();

    final updatedLog = dbService.getHabitLog(date);
    final activeForDate = state.habits.where((h) {
      final hDate = AppDateUtils.normalize(h.createdAt);
      final dNorm = AppDateUtils.normalize(date);
      return hDate.isBefore(dNorm) || hDate.isAtSameMomentAs(dNorm);
    }).toList();

    return activeForDate.isNotEmpty &&
        (updatedLog.completedHabitIds.length == activeForDate.length);
  }
}

final habitNotifierProvider =
    NotifierProvider<HabitNotifier, HabitState>(HabitNotifier.new);
