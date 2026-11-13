import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/settings_service.dart';

class SettingsController extends GetxController {
  final _s = Get.find<SettingsService>();

  Rx<ThemeMode> get themeMode => _s.themeMode;
  RxInt get defaultRemind => _s.defaultRemind;

  int get themeIndex => const [ThemeMode.system, ThemeMode.light, ThemeMode.dark]
      .indexOf(_s.themeMode.value);

  void setThemeIndex(int i) =>
      _s.setTheme(const [ThemeMode.system, ThemeMode.light, ThemeMode.dark][i]);

  void setDefaultRemind(int v) => _s.setDefaultRemind(v);
}
