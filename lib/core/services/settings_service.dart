import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database_service.dart';

class SettingsService extends GetxService {
  final _db = Get.find<DatabaseService>();

  final themeMode = ThemeMode.system.obs;
  final defaultRemind = 10.obs;
  final defaultPriority = 1.obs;
  final soundEnabled = true.obs;

  Future<SettingsService> init() async {
    final t = await _db.getSetting('theme');
    themeMode.value = switch (t) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final r = await _db.getSetting('remind');
    defaultRemind.value = int.tryParse(r ?? '') ?? 10;

    final p = await _db.getSetting('priority');
    defaultPriority.value = int.tryParse(p ?? '') ?? 1;

    final s = await _db.getSetting('sound');
    soundEnabled.value = (s ?? '1') == '1';

    return this;
  }

  Future<void> setTheme(ThemeMode m) async {
    themeMode.value = m;
    Get.changeThemeMode(m);
    await _db.setSetting('theme', m.name);
  }

  Future<void> setDefaultRemind(int v) async {
    defaultRemind.value = v;
    await _db.setSetting('remind', '$v');
  }

  Future<void> setDefaultPriority(int v) async {
    defaultPriority.value = v;
    await _db.setSetting('priority', '$v');
  }

  Future<void> setSoundEnabled(bool v) async {
    soundEnabled.value = v;
    await _db.setSetting('sound', v ? '1' : '0');
  }
}
