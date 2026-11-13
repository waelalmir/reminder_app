import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'glass_card.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final ValueChanged<int>? onToggleSubtask;
  final ValueChanged<Duration>? onSnooze;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onPin,
    this.onToggleSubtask,
    this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cat = taskCategories[task.category.clamp(0, taskCategories.length - 1)];
    final pColor = AppColors.priorityColors[task.priority.clamp(0, 2)];
    final late = task.isLate;

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderColor: late
          ? AppColors.danger.withValues(alpha: 0.45)
          : task.isPinned
              ? cs.primary.withValues(alpha: 0.4)
              : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شريط جانبي ملون يعكس الأولوية أو حالة التأخير
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: task.done
                    ? cs.outlineVariant
                    : (late ? AppColors.danger : pColor),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // زر الإنجاز الدائري الاحترافي
                        GestureDetector(
                          onTap: onToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(top: 2, left: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.done
                                  ? AppColors.success
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.done
                                    ? AppColors.success
                                    : (late ? AppColors.danger : cat.color),
                                width: 2.2,
                              ),
                            ),
                            child: task.done
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 17,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: AppFonts.heading.copyWith(
                                        decoration: task.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.done
                                            ? cs.onSurface.withValues(alpha: 0.45)
                                            : cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (task.repeatType > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.repeat_rounded,
                                        size: 17,
                                        color: cs.primary,
                                      ),
                                    ),
                                  InkWell(
                                    onTap: onPin,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        task.isPinned
                                            ? Icons.push_pin_rounded
                                            : Icons.push_pin_outlined,
                                        size: 18,
                                        color: task.isPinned
                                            ? cs.primary
                                            : cs.onSurface.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (task.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.note,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body.copyWith(
                                    fontSize: 13,
                                    color: cs.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    // عرض الخطوات الفرعية (Checklist) إن وجدت
                    if (task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 15,
                                  color: cs.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'الخطوات (${task.completedSubtasks}/${task.subtasks.length})',
                                  style: AppFonts.caption.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: task.subtasks.isEmpty
                                          ? 0
                                          : task.completedSubtasks /
                                              task.subtasks.length,
                                      minHeight: 5,
                                      backgroundColor:
                                          cs.primary.withValues(alpha: 0.12),
                                      valueColor:
                                          AlwaysStoppedAnimation(cs.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...List.generate(
                              task.subtasks.length > 3
                                  ? 3
                                  : task.subtasks.length,
                              (i) {
                                final sub = task.subtasks[i];
                                return GestureDetector(
                                  onTap: onToggleSubtask == null
                                      ? null
                                      : () => onToggleSubtask!(i),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2.5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          sub.done
                                              ? Icons.check_box_rounded
                                              : Icons
                                                  .check_box_outline_blank_rounded,
                                          size: 16,
                                          color: sub.done
                                              ? AppColors.success
                                              : cs.onSurface
                                                  .withValues(alpha: 0.45),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            sub.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFonts.small.copyWith(
                                              decoration: sub.done
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: sub.done
                                                  ? cs.onSurface
                                                      .withValues(alpha: 0.45)
                                                  : cs.onSurface
                                                      .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _pill(cat.icon, cat.name, cat.color),
                        _pill(
                          Icons.flag_rounded,
                          Fmt.priorityLabels[task.priority] ?? 'متوسطة',
                          pColor,
                        ),
                        if (task.due != null)
                          _pill(
                            Icons.schedule_rounded,
                            Fmt.dateTime(task.due!),
                            cs.primary,
                          ),
                        if (task.due != null && !task.done)
                          _pill(
                            late
                                ? Icons.warning_amber_rounded
                                : Icons.timelapse_rounded,
                            Fmt.left(task.due!),
                            late ? AppColors.danger : AppColors.success,
                          ),
                        if (late && !task.done && onSnooze != null)
                          InkWell(
                            onTap: () =>
                                onSnooze!(const Duration(minutes: 15)),
                            borderRadius: BorderRadius.circular(10),
                            child: _pill(
                              Icons.snooze_rounded,
                              '+15 د غفوة',
                              AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.5, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppFonts.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
