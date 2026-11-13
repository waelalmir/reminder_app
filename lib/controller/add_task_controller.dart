import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/services/database_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/settings_service.dart';
import '../data/models/task_model.dart';

class AddTaskController extends GetxController {
  final _db = Get.find<DatabaseService>();
  final _notif = Get.find<NotificationService>();
  final _settings = Get.find<SettingsService>();

  final Task? editing = Get.arguments as Task?;

  late final title = TextEditingController(text: editing?.title);
  late final note = TextEditingController(text: editing?.note);
  final amount = TextEditingController();
  final subtaskInput = TextEditingController();

  final cat = 0.obs;
  final remind = 10.obs;
  final priority = 1.obs; // 0: عادية, 1: متوسطة, 2: قصوى
  final repeatType = 0.obs; // 0: بدون, 1: يومي, 2: أسبوعي, 3: شهري
  final isPinned = false.obs;
  final unit = 1.obs;
  final due = Rxn<DateTime>();
  final subtasks = <SubTaskItem>[].obs;

  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    if (editing != null) {
      cat.value = editing!.category;
      remind.value = editing!.remindBefore;
      due.value = editing!.due;
      priority.value = editing!.priority;
      repeatType.value = editing!.repeatType;
      isPinned.value = editing!.isPinned;
      subtasks.assignAll(editing!.subtasks);
    } else {
      remind.value = _settings.defaultRemind.value;
      priority.value = _settings.defaultPriority.value;
    }
  }

  @override
  void onClose() {
    title.dispose();
    note.dispose();
    amount.dispose();
    subtaskInput.dispose();
    super.onClose();
  }

  void setAfter(Duration d) {
    HapticFeedback.selectionClick();
    final n = DateTime.now().add(d);
    due.value = DateTime(n.year, n.month, n.day, n.hour, n.minute);
  }

  void setTomorrowMorning() {
    HapticFeedback.selectionClick();
    final tom = DateTime.now().add(const Duration(days: 1));
    due.value = DateTime(tom.year, tom.month, tom.day, 9, 0);
  }

  void setTonight() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 20, 0);
    due.value = target.isAfter(now)
        ? target
        : target.add(const Duration(days: 1));
  }

  void applyCustom() {
    final n = int.tryParse(amount.text.trim());
    if (n == null || n <= 0) return;
    setAfter(switch (unit.value) {
      0 => Duration(minutes: n),
      1 => Duration(hours: n),
      _ => Duration(days: n),
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void addSubtask() {
    final text = subtaskInput.text.trim();
    if (text.isEmpty) return;
    subtasks.add(SubTaskItem(title: text));
    subtaskInput.clear();
    HapticFeedback.lightImpact();
  }

  void toggleSubtaskInForm(int index) {
    final item = subtasks[index];
    subtasks[index] = item.copyWith(done: !item.done);
  }

  void removeSubtask(int index) {
    subtasks.removeAt(index);
  }

  Future<void> pickDateTime() async {
    final now = DateTime.now();
    final base = (due.value != null && due.value!.isAfter(now))
        ? due.value!
        : now.add(const Duration(minutes: 30));

    final d = await showDatePicker(
      context: Get.context!,
      initialDate: base,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (t == null) return;

    due.value = DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال عنوان المهمة أو المشوار أولاً',
        margin: const EdgeInsets.all(14),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    // في حال كتب المستخدم خطوة فرعية في الحقل ولم يضغط زر الإضافة، نضيفها تلقائياً
    if (subtaskInput.text.trim().isNotEmpty) {
      addSubtask();
    }

    final t = Task(
      id: editing?.id,
      title: title.text.trim(),
      note: note.text.trim(),
      category: cat.value,
      dueAt: due.value?.millisecondsSinceEpoch,
      remindBefore: remind.value,
      done: editing?.done ?? false,
      createdAt: editing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      priority: priority.value,
      repeatType: repeatType.value,
      isPinned: isPinned.value,
      subtasks: subtasks.toList(),
    );

    if (t.id == null) {
      t.id = await _db.insertTask(t);
    } else {
      await _db.updateTask(t);
    }

    await _notif.schedule(t);
    HapticFeedback.mediumImpact();
    Get.back();
  }
}
