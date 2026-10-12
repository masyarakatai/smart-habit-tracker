import 'package:uuid/uuid.dart';

import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';
import 'plan_item.dart';

class PlanResult {
  final List<PlanItem> applied;

  /// Items that could not be applied, with the reason.
  final Map<PlanItem, String> skipped;

  const PlanResult(this.applied, this.skipped);
}

/// Applies the user-selected plan items using the same [HabitActions] as the
/// manual UI, so AI and manual changes share one code path.
class PlanExecutor {
  final HabitActions actions;
  final DateTime Function() now;
  final Uuid _uuid;

  PlanExecutor(this.actions, {DateTime Function()? now, Uuid? uuid})
      : now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  // Edits and log fixes first, then additions, deletions last.
  static const _order = [
    PlanItemType.updateHabit,
    PlanItemType.logChange,
    PlanItemType.addHabit,
    PlanItemType.deleteHabit,
  ];

  Future<PlanResult> apply(List<PlanItem> items) async {
    final applied = <PlanItem>[];
    final skipped = <PlanItem, String>{};
    final selected = items.where((i) => i.selected).toList()
      ..sort((a, b) => _order.indexOf(a.type).compareTo(_order.indexOf(b.type)));

    for (final item in selected) {
      final error = await _applyOne(item);
      if (error == null) {
        applied.add(item);
      } else {
        skipped[item] = error;
      }
    }
    return PlanResult(applied, skipped);
  }

  Future<String?> _applyOne(PlanItem item) async {
    Habit? existing;
    if (item.habitId != null) {
      for (final h in actions.currentHabits) {
        if (h.id == item.habitId) existing = h;
      }
    }

    switch (item.type) {
      case PlanItemType.addHabit:
        final title = item.title!;
        if (actions.currentHabits.any((h) => h.title.toLowerCase() == title.toLowerCase())) {
          return 'A habit with this name already exists';
        }
        await actions.addHabit(Habit(
          id: _uuid.v4(),
          title: title,
          description: item.description ?? '',
          iconCodePoint: item.iconCodePoint ?? 0xe57f,
          colorValue: item.colorValue ?? 0xFF6366F1,
          createdAt: now(),
        ));
        return null;

      case PlanItemType.updateHabit:
        if (existing == null) return 'Habit no longer exists';
        await actions.updateHabit(existing.copyWith(
          title: item.title,
          description: item.description,
          iconCodePoint: item.iconCodePoint,
          colorValue: item.colorValue,
        ));
        return null;

      case PlanItemType.deleteHabit:
        if (existing == null) return 'Habit no longer exists';
        await actions.deleteHabit(existing.id);
        return null;

      case PlanItemType.logChange:
        if (existing == null) return 'Habit no longer exists';
        await actions.setHabitCompletion(
            DateTime.parse(item.dateKey!), existing.id, item.completed!);
        return null;
    }
  }
}
