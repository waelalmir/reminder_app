import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/services/database_service.dart';
import '../core/services/notification_service.dart';
import '../data/models/task_model.dart';
import '../routes.dart';

class HomeController extends GetxController {
  final _db = Get.find<DatabaseService>();
  final _notif = Get.find<NotificationService>();

  final tasks = <Task>[].obs;
  final filter = 0.obs;
  final selectedCategory = (-1).obs; // -1 = جميع التصنيفات
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final loading = true.obs;
  final tick = 0.obs;
  Timer? _timer;

  static const filters = ['الكل', 'اليوم', 'المتأخرة', 'المكتملة'];

  @override
  void onInit() {
    super.onInit();
    load(reschedule: true);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => tick.value++);
  }

  @override
  void onClose() {
    _timer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  int get totalCount => tasks.length;
  int get pending => tasks.where((t) => !t.done).length;
  int get completedCount => tasks.where((t) => t.done).length;

  int get todayCount {
    final _ = tick.value;
    return tasks.where((t) => !t.done && t.isToday).length;
  }

  int get lateCount {
    final _ = tick.value;
    return tasks.where((t) => t.isLate).length;
  }

  double get completionRate {
    if (tasks.isEmpty) return 0;
    return completedCount / tasks.length;
  }

  void setSearch(String val) {
    searchQuery.value = val.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void selectCategory(int index) {
    if (selectedCategory.value == index) {
      selectedCategory.value = -1;
    } else {
      selectedCategory.value = index;
    }
  }

  List<Task> get shown {
    final _ = tick.value;
    final q = searchQuery.value.toLowerCase();
    final cat = selectedCategory.value;

    Iterable<Task> list = tasks;

    // 1. فلترة حسب التبويب المختار
    switch (filter.value) {
      case 0:
        list = list.where((t) => !t.done);
        break;
      case 1:
        list = list.where((t) => !t.done && t.isToday);
        break;
      case 2:
        list = list.where((t) => t.isLate);
        break;
      default:
        list = list.where((t) => t.done);
        break;
    }

    // 2. فلترة حسب التصنيف
    if (cat >= 0) {
      list = list.where((t) => t.category == cat);
    }

    // 3. فلترة حسب البحث النصي
    if (q.isNotEmpty) {
      list = list.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.note.toLowerCase().contains(q),
      );
    }

    return list.toList();
  }

  Future<void> load({bool reschedule = false}) async {
    final list = await _db.getTasks();
    if (reschedule) await _notif.rescheduleAll(list);
    tasks.assignAll(list);
    loading.value = false;
  }

  Future<void> openEditor([Task? t]) async {
    await Get.toNamed(Routes.add, arguments: t);
    await load();
  }

  Future<void> toggle(Task t) async {
    HapticFeedback.lightImpact();

    // إذا كانت المهمة متكررة وتم إنجازها، ننتقل للموعد التالي تلقائياً
    if (!t.done && t.repeatType > 0 && t.nextOccurrence != null) {
      final nextDate = t.nextOccurrence!;
      final resetSubtasks =
          t.subtasks.map((s) => s.copyWith(done: false)).toList();
      final nextTask = t.copyWith(
        dueAt: nextDate.millisecondsSinceEpoch,
        done: false,
        subtasks: resetSubtasks,
      );
      await _db.updateTask(nextTask);
      await _notif.schedule(nextTask);
      await load();

      Get.closeCurrentSnackbar();
      Get.showSnackbar(
        GetSnackBar(
          message: 'تم إنجاز الدورة الحالية وجدولة الموعد القادم تلقائياً 🔁',
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(14),
          borderRadius: 16,
          backgroundColor: const Color(0xFF1E293B),
        ),
      );
      return;
    }

    final n = t.copyWith(done: !t.done);
    await _db.updateTask(n);
    await _notif.schedule(n);
    await load();
  }

  Future<void> togglePin(Task t) async {
    HapticFeedback.selectionClick();
    final updated = t.copyWith(isPinned: !t.isPinned);
    await _db.updateTask(updated);
    await load();
  }

  Future<void> toggleSubtask(Task t, int subIndex) async {
    if (subIndex < 0 || subIndex >= t.subtasks.length) return;
    HapticFeedback.selectionClick();
    final updatedSubs = List<SubTaskItem>.from(t.subtasks);
    final item = updatedSubs[subIndex];
    updatedSubs[subIndex] = item.copyWith(done: !item.done);

    final updatedTask = t.copyWith(subtasks: updatedSubs);
    await _db.updateTask(updatedTask);
    await load();
  }

  Future<void> snoozeTask(Task t, Duration duration) async {
    HapticFeedback.mediumImpact();
    final base = (t.due != null && t.due!.isAfter(DateTime.now()))
        ? t.due!
        : DateTime.now();
    final nextTime = base.add(duration);
    final updated = t.copyWith(
      dueAt: nextTime.millisecondsSinceEpoch,
      done: false,
    );
    await _db.updateTask(updated);
    await _notif.schedule(updated);
    await load();
  }

  Future<void> clearCompleted() async {
    await _db.deleteCompletedTasks();
    await load();
  }

  Future<void> remove(Task t) async {
    HapticFeedback.mediumImpact();
    tasks.removeWhere((x) => x.id == t.id);
    await _db.deleteTask(t.id!);
    await _notif.cancel(t.id!);

    Get.closeCurrentSnackbar();
    Get.showSnackbar(
      GetSnackBar(
        message: 'تم حذف «${t.title}»',
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(14),
        borderRadius: 16,
        backgroundColor: const Color(0xFF1E293B),
        mainButton: TextButton(
          onPressed: () async {
            Get.closeCurrentSnackbar();
            final newId = await _db.insertTask(t);
            final restored = t.copyWith(id: newId);
            await _notif.schedule(restored);
            await load();
          },
          child: const Text(
            'تراجع',
            style: TextStyle(
              color: Color(0xFF818CF8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
