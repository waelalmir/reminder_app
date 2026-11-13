import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/notification_service.dart';
import '../core/services/settings_service.dart';
import 'home_controller.dart';

class SettingsController extends GetxController {
  final _s = Get.find<SettingsService>();
  final _notif = Get.find<NotificationService>();

  Rx<ThemeMode> get themeMode => _s.themeMode;
  RxInt get defaultRemind => _s.defaultRemind;
  RxInt get defaultPriority => _s.defaultPriority;
  RxBool get soundEnabled => _s.soundEnabled;

  RxBool get notificationsGranted => _notif.notificationsGranted;
  RxBool get exactAlarmsGranted => _notif.exactAlarmsGranted;
  RxInt get pendingCount => _notif.pendingCount;

  @override
  void onInit() {
    super.onInit();
    _notif.checkPermissionsStatus();
    _notif.refreshPendingCount();
  }

  int get themeIndex =>
      const [ThemeMode.system, ThemeMode.light, ThemeMode.dark]
          .indexOf(_s.themeMode.value);

  void setThemeIndex(int i) =>
      _s.setTheme(const [ThemeMode.system, ThemeMode.light, ThemeMode.dark][i]);

  void setDefaultRemind(int v) => _s.setDefaultRemind(v);

  void setDefaultPriority(int v) => _s.setDefaultPriority(v);

  Future<void> toggleSound(bool v) async {
    await _s.setSoundEnabled(v);
    if (Get.isRegistered<HomeController>()) {
      await _notif.rescheduleAll(Get.find<HomeController>().tasks);
    }
  }

  Future<void> testNotification() async {
    await _notif.sendTestNotification();
    Get.snackbar(
      'تم إرسال الإشعار التجريبي 🔔',
      'تحقق من شريط الإشعارات في أعلى الشاشة للتأكد من الصوت والتنبيه.',
      margin: const EdgeInsets.all(14),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> requestPermissionsAgain() async {
    await _notif.requestPermissions();
    await _notif.refreshPendingCount();
  }
}
