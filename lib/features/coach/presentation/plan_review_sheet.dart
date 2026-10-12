import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../coach_providers.dart';
import '../domain/plan_item.dart';

/// Bottom sheet listing the coach's proposed changes. Only ticked items are
/// applied when the user presses Schedule.
class PlanReviewSheet extends ConsumerStatefulWidget {
  const PlanReviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlanReviewSheet(),
    );
  }

  @override
  ConsumerState<PlanReviewSheet> createState() => _PlanReviewSheetState();
}

class _PlanReviewSheetState extends ConsumerState<PlanReviewSheet> {
  bool _applying = false;

  Future<void> _schedule() async {
    setState(() => _applying = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result = await ref.read(coachControllerProvider.notifier).applyPlan();
    navigator.pop();

    final applied = result.applied.length;
    final skipped = result.skipped.length;
    messenger.showSnackBar(SnackBar(
      content: Text(
        'Scheduled $applied change${applied == 1 ? '' : 's'}'
        '${skipped > 0 ? ' · $skipped skipped (${result.skipped.values.first})' : ''}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coach = ref.watch(coachControllerProvider);
    final plan = coach.plan;
    final selected = coach.selectedCount;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Review your plan',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Untick anything you don\'t want. Nothing changes until you press Schedule.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (plan.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No proposed changes', style: GoogleFonts.inter())),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in plan)
                      _PlanItemTile(
                        item: item,
                        isDark: isDark,
                        onChanged: _applying
                            ? null
                            : () => ref.read(coachControllerProvider.notifier).toggleItem(item.id),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: _applying || plan.isEmpty
                      ? null
                      : () {
                          ref.read(coachControllerProvider.notifier).discardPlan();
                          Navigator.of(context).pop();
                        },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Discard all'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _applying || selected == 0 ? null : _schedule,
                  icon: _applying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.event_available_rounded),
                  label: Text('Schedule $selected'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanItemTile extends StatelessWidget {
  final PlanItem item;
  final bool isDark;
  final VoidCallback? onChanged;

  const _PlanItemTile({required this.item, required this.isDark, required this.onChanged});

  ({IconData icon, Color color, String label}) get _style {
    switch (item.type) {
      case PlanItemType.addHabit:
        return (icon: Icons.add_circle_outline_rounded, color: AppColors.success, label: 'ADD');
      case PlanItemType.updateHabit:
        return (icon: Icons.edit_outlined, color: AppColors.primary, label: 'EDIT');
      case PlanItemType.deleteHabit:
        return (icon: Icons.delete_outline_rounded, color: AppColors.error, label: 'DELETE');
      case PlanItemType.logChange:
        return (icon: Icons.history_rounded, color: AppColors.warning, label: 'LOG');
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.selected
              ? style.color.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
        ),
      ),
      child: CheckboxListTile(
        value: item.selected,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        secondary: Icon(style.icon, color: style.color),
        title: Text(
          item.summary,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.type == PlanItemType.addHabit && (item.description ?? '').isNotEmpty)
              Text(item.description!, style: GoogleFonts.inter(fontSize: 12, color: secondary)),
            if (item.reason.isNotEmpty)
              Text(item.reason,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: secondary, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
