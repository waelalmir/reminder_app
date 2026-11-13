import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/database_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/settings_service.dart';
import '../data/models/task_model.dart';

class AddTaskController extends GetxController {
  final _db = Get.find<DatabaseService>();
  final _notif = Get.find<NotificationService>();

  final Task? editing = Get.arguments as Task?;

  late final title = TextEditingController(text: editing?.title);
  late final note = TextEditingController(text: editing?.note);
  final amount = TextEditingController();

  final cat = 0.obs;
  final remind = 0.obs;
  final unit = 1.obs; // 0 دقائق، 1 ساعات، 2 أيام
  final due = Rxn<DateTime>();

  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    if (editing != null) {
      cat.value = editing!.category;
      remind.value = editing!.remindBefore;
      due.value = editing!.due;
    } else {
      remind.value = Get.find<SettingsService>().defaultRemind.value;
    }
  }

  @override
  void onClose() {
    title.dispose();
    note.dispose();
    amount.dispose();
    super.onClose();
  }

  void setAfter(Duration d) {
    final n = DateTime.now().add(d);
    due.value = DateTime(n.year, n.month, n.day, n.hour, n.minute);
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

  Future<void> pickDateTime() async {
    final base = due.value ?? DateTime.now();
    final d = await showDatePicker(
      context: Get.context!,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final t = await showTimePicker(
        context: Get.context!, initialTime: TimeOfDay.fromDateTime(base));
    if (t == null) return;
    due.value = DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'اكتب عنوانًا أولاً',
          margin: const EdgeInsets.all(12), snackPosition: SnackPosition.BOTTOM);
      return;
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
    );
    if (t.id == null) {
      t.id = await _db.insertTask(t);
    } else {
      await _db.updateTask(t);
    }
    await _notif.schedule(t);
    Get.back();
  }
}
