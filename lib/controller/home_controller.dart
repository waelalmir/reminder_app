import 'dart:async';

import 'package:flutter/material.dart';
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
  final loading = true.obs;
  final tick = 0.obs; // يتحدّث كل دقيقة لتحديث العدّادات
  Timer? _timer;

  static const filters = ['المتبقية', 'اليوم', 'متأخرة', 'منجزة'];

  @override
  void onInit() {
    super.onInit();
    load(reschedule: true);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => tick.value++);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  int get pending => tasks.where((t) => !t.done).length;

  int get lateCount {
    final _ = tick.value;
    return tasks.where((t) => t.isLate).length;
  }

  List<Task> get shown {
    final _ = tick.value;
    final now = DateTime.now();
    switch (filter.value) {
      case 0:
        return tasks.where((t) => !t.done).toList();
      case 1:
        return tasks.where((t) {
          final d = t.due;
          return !t.done &&
              d != null &&
              d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
        }).toList();
      case 2:
        return tasks.where((t) => t.isLate).toList();
      default:
        return tasks.where((t) => t.done).toList();
    }
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
    final n = t.copyWith(done: !t.done);
    await _db.updateTask(n);
    await _notif.schedule(n);
    await load();
  }

  Future<void> remove(Task t) async {
    tasks.removeWhere((x) => x.id == t.id); // فورًا لتفادي خطأ Dismissible
    await _db.deleteTask(t.id!);
    await _notif.cancel(t.id!);

    Get.closeCurrentSnackbar();
    Get.showSnackbar(GetSnackBar(
      message: 'تم حذف «${t.title}»',
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      mainButton: TextButton(
        onPressed: () async {
          Get.closeCurrentSnackbar();
          await _db.insertTask(t); // يحافظ على نفس المعرّف
          await _notif.schedule(t);
          await load();
        },
        child: const Text('تراجع'),
      ),
    ));
  }
}
