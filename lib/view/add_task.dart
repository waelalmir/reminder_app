import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_task_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../core/utils/formatters.dart';
import '../data/models/category_model.dart';
import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/pill_toggle.dart';

class AddTaskView extends GetView<AddTaskController> {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(controller.isEdit ? 'تعديل المهمة' : 'مهمة جديدة'),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'تثبيت في الأعلى',
              onPressed: () =>
                  controller.isPinned.value = !controller.isPinned.value,
              icon: Icon(
                controller.isPinned.value
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                color: controller.isPinned.value ? cs.primary : cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: FilledButton.icon(
            onPressed: controller.save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.seed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Icon(
              controller.isEdit ? Icons.check_circle_rounded : Icons.add_rounded,
            ),
            label: Text(
              controller.isEdit ? 'حفظ التعديلات' : 'إضافة المهمة وجدولة التنبيه',
              style: AppFonts.heading.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // 1. العنوان والملاحظات
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تفاصيل المهمة', style: AppFonts.heading),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.title,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'عنوان المهمة أو المشوار...',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.note,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'ملاحظات إضافية أو تفاصيل (اختياري)...',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. الأولوية والتصنيف
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الأولوية', style: AppFonts.heading),
                    const SizedBox(height: 10),
                    Obx(
                      () => PillToggle(
                        items: const ['عادية 🟢', 'متوسطة 🟠', 'قصوى 🔴'],
                        selected: controller.priority.value,
                        onChanged: (v) => controller.priority.value = v,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('التصنيف', style: AppFonts.heading),
                    const SizedBox(height: 10),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(taskCategories.length, (i) {
                          final c = taskCategories[i];
                          final selected = controller.cat.value == i;
                          return GestureDetector(
                            onTap: () => controller.cat.value = i,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? c.color
                                    : c.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? c.color
                                      : c.color.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    c.icon,
                                    size: 16,
                                    color: selected ? Colors.white : c.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    c.name,
                                    style: AppFonts.small.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: selected ? Colors.white : c.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. الموعد، التكرار، والتذكير الذكي
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الموعد والتنبيه', style: AppFonts.heading),
                        Obx(
                          () => controller.due.value != null
                              ? TextButton.icon(
                                  onPressed: () => controller.due.value = null,
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  label: const Text('مسح الموعد'),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final d = controller.due.value;
                      return InkWell(
                        onTap: controller.pickDateTime,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: cs.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  d == null
                                      ? 'اضغط لاختيار التاريخ والوقت المحدد'
                                      : '${Fmt.dateTime(d)} (${Fmt.left(d)})',
                                  style: AppFonts.subheading.copyWith(
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                              Icon(Icons.edit_calendar_rounded,
                                  size: 18, color: cs.primary),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      'اختصارات سريعة للموعد:',
                      style: AppFonts.small.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickTimeChip(
                          label: 'بعد 15 د',
                          onTap: () =>
                              controller.setAfter(const Duration(minutes: 15)),
                        ),
                        _QuickTimeChip(
                          label: 'بعد ساعة',
                          onTap: () =>
                              controller.setAfter(const Duration(hours: 1)),
                        ),
                        _QuickTimeChip(
                          label: 'بعد 3 ساعات',
                          onTap: () =>
                              controller.setAfter(const Duration(hours: 3)),
                        ),
                        _QuickTimeChip(
                          label: 'اليوم 8 مساءً',
                          onTap: controller.setTonight,
                        ),
                        _QuickTimeChip(
                          label: 'غداً 9 صباحاً',
                          onTap: controller.setTomorrowMorning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: controller.amount,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'مدة مخصصة...',
                            ),
                            onSubmitted: (_) => controller.applyCustom(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Obx(
                            () => PillToggle(
                              items: const ['دقيقة', 'ساعة', 'يوم'],
                              selected: controller.unit.value,
                              onChanged: (v) => controller.unit.value = v,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: controller.applyCustom,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('تطبيق'),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        Icon(Icons.notifications_active_rounded,
                            size: 20, color: cs.primary),
                        const SizedBox(width: 8),
                        Text('التذكير الاستباقي:', style: AppFonts.subheading),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<int>(
                        value: Fmt.remindOptions
                                .containsKey(controller.remind.value)
                            ? controller.remind.value
                            : 0,
                        items: Fmt.remindOptions.entries
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e.key,
                                child: Text(e.value, style: AppFonts.body),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.remind.value = v;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.repeat_rounded, size: 20, color: cs.primary),
                        const SizedBox(width: 8),
                        Text('تكرار المهمة:', style: AppFonts.subheading),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<int>(
                        value: controller.repeatType.value,
                        items: Fmt.repeatOptions.entries
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e.key,
                                child: Text(e.value, style: AppFonts.body),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.repeatType.value = v;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. قائمة الخطوات الفرعية (Subtasks Checklist)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الخطوات الفرعية (Checklist)', style: AppFonts.heading),
                    const SizedBox(height: 4),
                    Text(
                      'قسّم المهمة الكبيرة أو أغراض التسوق إلى عناصر فرعية',
                      style: AppFonts.small.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.subtaskInput,
                            decoration: const InputDecoration(
                              hintText: 'أضف خطوة أو غرضاً...',
                            ),
                            onSubmitted: (_) => controller.addSubtask(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: controller.addSubtask,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        children: List.generate(
                          controller.subtasks.length,
                          (i) {
                            final item = controller.subtasks[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Checkbox(
                                value: item.done,
                                onChanged: (_) =>
                                    controller.toggleSubtaskInForm(i),
                              ),
                              title: Text(
                                item.title,
                                style: AppFonts.body.copyWith(
                                  decoration: item.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => controller.removeSubtask(i),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickTimeChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(Icons.bolt_rounded, size: 15, color: cs.primary),
      label: Text(label),
      backgroundColor: cs.primary.withValues(alpha: 0.09),
    );
  }
}
