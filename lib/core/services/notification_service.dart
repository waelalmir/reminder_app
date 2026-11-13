import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';

class NotificationService extends GetxService {
  final _p = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'tasks_channel_v2', // غيّر الرقم (v3, v4…) كلما غيّرت النغمة
      'تذكير المهام',
      channelDescription: 'إشعارات مواعيد المهام والملاحظات',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'notify',
      ), // res/raw/notify.wav
      enableVibration: true,
    ),
  );

  Future<NotificationService> init() async {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {}

    await _p.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final a = _p
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await a?.requestNotificationsPermission();
    await a?.requestExactAlarmsPermission();
    return this;
  }

  String _body(int before) {
    if (before == 0) return 'حان موعد هذه المهمة ⏰';
    if (before < 60) return 'تبقّى $before دقيقة على الموعد';
    if (before < 1440) return 'تبقّى ${before ~/ 60} ساعة على الموعد';
    return 'تبقّى ${before ~/ 1440} يوم على الموعد';
  }

  /// يجدول (أو يلغي) إشعار المهمة حسب حالتها.
  Future<void> schedule(Task t) async {
    if (t.id == null) return;
    await _p.cancel(t.id!);
    if (t.done || t.due == null) return;

    final when = t.due!.subtract(Duration(minutes: t.remindBefore));
    if (when.isBefore(DateTime.now())) return;

    final at = tz.TZDateTime.from(when, tz.local);
    try {
      await _p.zonedSchedule(
        t.id!,
        t.title,
        _body(t.remindBefore),
        at,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _p.zonedSchedule(
        t.id!,
        t.title,
        _body(t.remindBefore),
        at,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancel(int id) => _p.cancel(id);

  Future<void> rescheduleAll(List<Task> tasks) async {
    for (final t in tasks) {
      await schedule(t);
    }
  }
}
