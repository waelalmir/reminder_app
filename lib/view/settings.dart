import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/settings_controller.dart';
import '../core/theme/app_fonts.dart';
import '../core/utils/formatters.dart';
import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/pill_toggle.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  Widget _title(IconData i, String s, ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(i, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Text(s, style: AppFonts.heading),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('الإعدادات')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(Icons.palette_rounded, 'المظهر', cs),
                  Obx(() {
                    controller.themeMode.value; // للاشتراك بالتغيير
                    return PillToggle(
                      items: const ['تلقائي', 'فاتح', 'داكن'],
                      index: controller.themeIndex,
                      onChanged: controller.setThemeIndex,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(Icons.notifications_active_rounded,
                      'التذكير الافتراضي للمهام الجديدة', cs),
                  Obx(() => DropdownButtonFormField<int>(
                        initialValue: controller.defaultRemind.value,
                        items: [
                          for (final e in Fmt.remindOptions.entries)
                            DropdownMenuItem(value: e.key, child: Text(e.value)),
                        ],
                        onChanged: (v) => controller.setDefaultRemind(v ?? 0),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'كل بياناتك محفوظة على جهازك فقط، والتطبيق يعمل بدون إنترنت.',
                      style: AppFonts.body
                          .copyWith(color: cs.onSurface.withValues(alpha: .75)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
