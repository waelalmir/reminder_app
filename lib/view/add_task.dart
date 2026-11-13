import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_task_controller.dart';
import '../core/theme/app_fonts.dart';
import '../core/utils/formatters.dart';
import '../data/models/category_model.dart';
import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/pill_toggle.dart';

class AddTaskView extends GetView<AddTaskController> {
  const AddTaskView({super.key});

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: Text(s, style: AppFonts.heading),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final quick = <String, Duration>{
      'بعد ساعة': const Duration(hours: 1),
      'بعد 3 ساعات': const Duration(hours: 3),
      'غدًا': const Duration(days: 1),
      'بعد 3 أيام': const Duration(days: 3),
      'بعد أسبوع': const Duration(days: 7),
    };

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Text(controller.isEdit ? 'تعديل المهمة' : 'مهمة جديدة')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: controller.save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('حفظ', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'العنوان', prefixIcon: Icon(Icons.edit_rounded)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller.note,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  prefixIcon: Icon(Icons.notes_rounded)),
            ),
            const SizedBox(height: 22),

            _label('النوع'),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < taskCategories.length; i++)
                      ChoiceChip(
                        avatar: Icon(taskCategories[i].icon,
                            size: 18,
                            color: controller.cat.value == i
                                ? Colors.white
                                : taskCategories[i].color),
                        label: Text(taskCategories[i].name),
                        selected: controller.cat.value == i,
                        selectedColor: taskCategories[i].color,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                            color:
                                controller.cat.value == i ? Colors.white : null),
                        onSelected: (_) => controller.cat.value = i,
                      ),
                  ],
                )),
            const SizedBox(height: 22),

            _label('الموعد النهائي'),
            Obx(() {
              final d = controller.due.value;
              return GlassCard(
                blur: 0,
                radius: 20,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onTap: controller.pickDateTime,
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d == null ? 'بدون موعد' : Fmt.dateTime(d),
                              style: AppFonts.heading),
                          if (d != null)
                            Text(Fmt.left(d),
                                style: AppFonts.small.copyWith(
                                    color: cs.onSurface.withValues(alpha: .6))),
                        ],
                      ),
                    ),
                    if (d != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => controller.due.value = null,
                      )
                    else
                      const Icon(Icons.chevron_left_rounded),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in quick.entries)
                  ActionChip(
                    label: Text(e.key),
                    onPressed: () => controller.setAfter(e.value),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 84,
                  child: TextField(
                    controller: controller.amount,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'بعد…'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => PillToggle(
                        items: const ['دقائق', 'ساعات', 'أيام'],
                        index: controller.unit.value,
                        onChanged: (i) => controller.unit.value = i,
                      )),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  onPressed: controller.applyCustom,
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),

            Obx(() {
              if (controller.due.value == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  _label('التذكير'),
                  DropdownButtonFormField<int>(
                    initialValue: Fmt.remindOptions.containsKey(controller.remind.value)
                        ? controller.remind.value
                        : 0,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.notifications_active_rounded)),
                    items: [
                      for (final e in Fmt.remindOptions.entries)
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    onChanged: (v) => controller.remind.value = v ?? 0,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
