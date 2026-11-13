import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../controller/home_controller.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'database_service.dart';
import 'settings_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Handled when app resumes or via action IDs
}

class NotificationService extends GetxService {
  final _p = FlutterLocalNotificationsPlugin();

  final notificationsGranted = false.obs;
  final exactAlarmsGranted = false.obs;
  final pendingCount = 0.obs;

  static const _channelId = 'tasks_channel_v3';
  static const _channelName = 'تنبيهات المهام والمشاوير';
  static const _channelDesc = 'إشعارات ذكية لتذكيرك بمواعيد المهام والمشاوير';

  static const _silentChannelId = 'tasks_channel_silent_v3';
  static const _silentChannelName = 'تنبيهات صامتة';

  static const actionDone = 'ACTION_MARK_DONE';
  static const actionSnooze10 = 'ACTION_SNOOZE_10';

  // نستخدم معرفين لكل مهمة:
  // 1) id * 10 + 1 -> للتنبيه الاستباقي (قبل الموعد بـ remindBefore)
  // 2) id * 10 + 2 -> للتنبيه الأساسي عند حلول موعد المهمة بالضبط
  int _preId(int taskId) => taskId * 10 + 1;
  int _dueId(int taskId) => taskId * 10 + 2;

  AndroidNotificationDetails _buildAndroidDetails({
    required String body,
    required String categoryName,
    bool withActions = true,
  }) {
    final soundOn = Get.find<SettingsService>().soundEnabled.value;
    return AndroidNotificationDetails(
      soundOn ? _channelId : _silentChannelId,
      soundOn ? _channelName : _silentChannelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundOn,
      sound: soundOn ? const RawResourceAndroidNotificationSound('notify') : null,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      subText: categoryName,
      styleInformation: BigTextStyleInformation(body),
      actions: withActions
          ? const <AndroidNotificationAction>[
              AndroidNotificationAction(
                actionDone,
                'إنجاز المهمة ✓',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                actionSnooze10,
                'غفوة 10 دقائق ⏰',
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ]
          : null,
    );
  }

  Future<NotificationService> init() async {
    tzdata.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _p.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await requestPermissions();
    await refreshPendingCount();
    return this;
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final dynamic rawTz = await FlutterTimezone.getLocalTimezone();
      final String tzName = rawTz is String
          ? rawTz
          : (rawTz.toString().contains('(')
              ? rawTz.toString().split('(').first.trim()
              : rawTz.toString());
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
      } catch (_) {}
    }
  }

  Future<void> requestPermissions() async {
    final android = _p.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    try {
      final notifPerm = await android.requestNotificationsPermission();
      notificationsGranted.value = notifPerm ?? false;
    } catch (_) {}

    try {
      final exactPerm = await android.requestExactAlarmsPermission();
      exactAlarmsGranted.value = exactPerm ?? false;
    } catch (_) {}

    await checkPermissionsStatus();
  }

  Future<void> checkPermissionsStatus() async {
    final android = _p.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    try {
      final enabled = await android.areNotificationsEnabled();
      if (enabled != null) notificationsGranted.value = enabled;
    } catch (_) {}

    try {
      final exact = await android.canScheduleExactNotifications();
      if (exact != null) exactAlarmsGranted.value = exact;
    } catch (_) {}
  }

  Future<void> refreshPendingCount() async {
    try {
      final list = await _p.pendingNotificationRequests();
      pendingCount.value = list.length;
    } catch (_) {
      pendingCount.value = 0;
    }
  }

  Future<void> _onNotificationResponse(NotificationResponse res) async {
    final payload = res.payload;
    if (payload == null) return;
    final taskId = int.tryParse(payload);
    if (taskId == null) return;

    final db = Get.find<DatabaseService>();
    final task = await db.getTaskById(taskId);
    if (task == null) return;

    if (res.actionId == actionDone) {
      if (task.repeatType > 0 && task.nextOccurrence != null) {
        final nextDue = task.nextOccurrence!;
        final updated = task.copyWith(
          dueAt: nextDue.millisecondsSinceEpoch,
          done: false,
        );
        await db.updateTask(updated);
        await schedule(updated);
      } else {
        final updated = task.copyWith(done: true);
        await db.updateTask(updated);
        await cancel(taskId);
      }
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().load();
      }
    } else if (res.actionId == actionSnooze10) {
      final snoozedTime = DateTime.now().add(const Duration(minutes: 10));
      final updated = task.copyWith(
        dueAt: snoozedTime.millisecondsSinceEpoch,
        done: false,
      );
      await db.updateTask(updated);
      await schedule(updated);
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().load();
      }
    } else {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().openEditor(task);
      }
    }
  }

  String _preReminderBody(int before, String note) {
    final prefix = switch (before) {
      < 60 => 'متبقي $before دقيقة على الموعد المحدد ⏳',
      < 1440 => 'متبقي ${before ~/ 60} ساعة على الموعد المحدد ⏳',
      _ => 'متبقي ${before ~/ 1440} يوم على الموعد المحدد 📅',
    };
    return note.trim().isEmpty ? prefix : '$prefix\n$note';
  }

  String _dueNowBody(String note) {
    const base = 'حان موعد المهمة الآن! انقر للإنجاز أو الغفوة ⏰';
    return note.trim().isEmpty ? base : '$base\n$note';
  }

  DateTimeComponents? _matchComponentsForRepeat(int repeatType) {
    return switch (repeatType) {
      1 => DateTimeComponents.time,
      2 => DateTimeComponents.dayOfWeekAndTime,
      3 => DateTimeComponents.dayOfMonthAndTime,
      _ => null,
    };
  }

  Future<void> _zonedScheduleSafe({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required NotificationDetails details,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _p.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      try {
        await _p.zonedSchedule(
          id,
          title,
          body,
          scheduledAt,
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      } catch (_) {}
    }
  }

  Future<void> schedule(Task t) async {
    if (t.id == null) return;
    await cancel(t.id!);

    if (t.done || t.due == null) {
      await refreshPendingCount();
      return;
    }

    await _configureLocalTimeZone();

    final now = DateTime.now();
    DateTime targetDue = t.due!;

    // إذا كانت المهمة متكررة وموعدها في الماضي، نجدولها على الموعد القادم تلقائياً
    if (targetDue.isBefore(now) && t.repeatType > 0 && t.nextOccurrence != null) {
      targetDue = t.nextOccurrence!;
    }

    // إذا كان الموعد النهائي قد مضى بالكامل (وليست مهمة متكررة)، لا نجدول
    if (targetDue.isBefore(now)) {
      await refreshPendingCount();
      return;
    }

    final catIndex = t.category.clamp(0, taskCategories.length - 1);
    final catName = taskCategories[catIndex].name;
    final repeatMatch = _matchComponentsForRepeat(t.repeatType);

    // 1. جدولة التنبيه الاستباقي (إذا كان المستخدم قد اختار تذكيراً قبل الموعد وكان وقت التذكير لم يمضِ بعد)
    if (t.remindBefore > 0) {
      final preTime = targetDue.subtract(Duration(minutes: t.remindBefore));
      if (preTime.isAfter(now)) {
        final preBody = _preReminderBody(t.remindBefore, t.note);
        final preDetails = NotificationDetails(
          android: _buildAndroidDetails(
            body: preBody,
            categoryName: 'تذكير استباقي • $catName',
          ),
        );
        await _zonedScheduleSafe(
          id: _preId(t.id!),
          title: 'قريباً: ${t.title}',
          body: preBody,
          scheduledAt: tz.TZDateTime.from(preTime, tz.local),
          details: preDetails,
          payload: '${t.id}',
          matchDateTimeComponents: repeatMatch,
        );
      }
    }

    // 2. جدولة التنبيه الأساسي عند حلول الموعد بالضبط (حتى لو مضى وقت التذكير الاستباقي!)
    final dueBody = _dueNowBody(t.note);
    final dueDetails = NotificationDetails(
      android: _buildAndroidDetails(
        body: dueBody,
        categoryName: 'الموعد الآن • $catName',
      ),
    );
    await _zonedScheduleSafe(
      id: _dueId(t.id!),
      title: t.title,
      body: dueBody,
      scheduledAt: tz.TZDateTime.from(targetDue, tz.local),
      details: dueDetails,
      payload: '${t.id}',
      matchDateTimeComponents: repeatMatch,
    );

    await refreshPendingCount();
  }

  Future<void> sendTestNotification() async {
    await requestPermissions();
    const body =
        'نظام الإشعارات والصوت يعمل بنجاح وجاهز لتنبيهك بمواعيدك القادمة.';
    final details = NotificationDetails(
      android: _buildAndroidDetails(
        body: body,
        categoryName: 'فحص النظام',
        withActions: false,
      ),
    );
    await _p.show(
      999999,
      'تجربة إشعار مُذكّري 🔔',
      body,
      details,
    );
  }

  Future<void> cancel(int taskId) async {
    try {
      // إلغاء المعرف القديم (في الإصدار السابق) والمعرفين الجديدين
      await _p.cancel(taskId);
      await _p.cancel(_preId(taskId));
      await _p.cancel(_dueId(taskId));
    } catch (_) {}
    await refreshPendingCount();
  }

  Future<void> rescheduleAll(List<Task> tasks) async {
    for (final t in tasks) {
      await schedule(t);
    }
    await refreshPendingCount();
  }
}
