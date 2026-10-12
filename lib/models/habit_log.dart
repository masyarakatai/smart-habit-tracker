/// Data model representing daily habit completions.
/// The `dateKey` is formatted as "YYYY-MM-DD".
class HabitLog {
  final String dateKey;
  final Set<String> completedHabitIds;

  HabitLog({
    required this.dateKey,
    required this.completedHabitIds,
  });

  bool isHabitCompleted(String habitId) => completedHabitIds.contains(habitId);

  HabitLog copyWith({
    String? dateKey,
    Set<String>? completedHabitIds,
  }) {
    return HabitLog(
      dateKey: dateKey ?? this.dateKey,
      completedHabitIds: completedHabitIds ?? this.completedHabitIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'completedHabitIds': completedHabitIds.toList(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      dateKey: map['dateKey'] as String,
      completedHabitIds: (map['completedHabitIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
    );
  }
}
