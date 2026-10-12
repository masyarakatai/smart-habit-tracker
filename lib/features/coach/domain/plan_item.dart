enum PlanItemType { addHabit, updateHabit, deleteHabit, logChange }

/// One change the AI coach proposed. Nothing is applied until the user
/// presses "Schedule" with this item ticked.
class PlanItem {
  final String id;
  final PlanItemType type;

  /// Existing habit (update / delete / logChange).
  final String? habitId;

  /// Habit title at proposal time, for display.
  final String? habitTitle;

  /// New values (add / update). Null means "unchanged".
  final String? title;
  final String? description;
  final int? iconCodePoint;
  final int? colorValue;

  /// For logChange.
  final String? dateKey;
  final bool? completed;

  /// The coach's short explanation, shown under the item.
  final String reason;

  final bool selected;

  const PlanItem({
    required this.id,
    required this.type,
    this.habitId,
    this.habitTitle,
    this.title,
    this.description,
    this.iconCodePoint,
    this.colorValue,
    this.dateKey,
    this.completed,
    this.reason = '',
    this.selected = true,
  });

  PlanItem copyWith({bool? selected}) => PlanItem(
        id: id,
        type: type,
        habitId: habitId,
        habitTitle: habitTitle,
        title: title,
        description: description,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        dateKey: dateKey,
        completed: completed,
        reason: reason,
        selected: selected ?? this.selected,
      );

  /// One-line summary for the plan review sheet and chat events.
  String get summary {
    switch (type) {
      case PlanItemType.addHabit:
        return 'Add "$title"';
      case PlanItemType.updateHabit:
        final changes = [
          if (title != null) 'rename to "$title"',
          if (description != null) 'new description',
          if (iconCodePoint != null) 'new icon',
          if (colorValue != null) 'new color',
        ];
        return 'Edit "$habitTitle": ${changes.join(', ')}';
      case PlanItemType.deleteHabit:
        return 'Delete "$habitTitle"';
      case PlanItemType.logChange:
        return '${completed == true ? 'Mark' : 'Unmark'} "$habitTitle" '
            '${completed == true ? 'done' : 'not done'} on $dateKey';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'habitId': habitId,
        'habitTitle': habitTitle,
        'title': title,
        'description': description,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'dateKey': dateKey,
        'completed': completed,
        'reason': reason,
        'selected': selected,
      };

  factory PlanItem.fromMap(Map map) => PlanItem(
        id: map['id'] as String,
        type: PlanItemType.values.byName(map['type'] as String),
        habitId: map['habitId'] as String?,
        habitTitle: map['habitTitle'] as String?,
        title: map['title'] as String?,
        description: map['description'] as String?,
        iconCodePoint: map['iconCodePoint'] as int?,
        colorValue: map['colorValue'] as int?,
        dateKey: map['dateKey'] as String?,
        completed: map['completed'] as bool?,
        reason: (map['reason'] as String?) ?? '',
        selected: (map['selected'] as bool?) ?? true,
      );
}
