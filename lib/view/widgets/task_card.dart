import 'package:flutter/material.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'glass_card.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  Widget _pill(String text, Color color, {IconData? icon}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: AppFonts.small
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = taskCategories[task.category];
    final due = task.due;
    final late = task.isLate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        blur: 0,
        radius: 22,
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        borderColor: late ? cs.error.withValues(alpha: .6) : null,
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.done ? c.color : c.color.withValues(alpha: .15),
                ),
                child: Icon(task.done ? Icons.check_rounded : c.icon,
                    color: task.done ? Colors.white : c.color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppFonts.heading.copyWith(
                      decoration: task.done ? TextDecoration.lineThrough : null,
                      color: task.done
                          ? cs.onSurface.withValues(alpha: .45)
                          : cs.onSurface,
                    ),
                  ),
                  if (task.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(task.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body
                            .copyWith(color: cs.onSurface.withValues(alpha: .6))),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _pill(c.name, c.color),
                      if (due != null)
                        _pill(
                          task.done ? Fmt.dateTime(due) : Fmt.left(due),
                          late ? cs.error : cs.primary,
                          icon: Icons.schedule_rounded,
                        ),
                    ],
                  ),
                  if (due != null && !task.done)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(Fmt.dateTime(due),
                          style: AppFonts.small
                              .copyWith(color: cs.onSurface.withValues(alpha: .5))),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
