import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database_service.dart';

class SettingsService extends GetxService {
  final _db = Get.find<DatabaseService>();

  final themeMode = ThemeMode.system.obs;
  final defaultRemind = 0.obs; // دقائق

  Future<SettingsService> init() async {
    final t = await _db.getSetting('theme');
    themeMode.value = switch (t) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    defaultRemind.value =
        int.tryParse(await _db.getSetting('remind') ?? '') ?? 0;
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
}
