import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/settings_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../core/utils/formatters.dart';
import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/pill_toggle.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('الإعدادات وفحص الإشعارات')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. المظهر والألوان
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_rounded, color: cs.primary),
                        const SizedBox(width: 8),
                        Text('المظهر العام', style: AppFonts.heading),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => PillToggle(
                        items: const ['تلقائي', 'نهاري ☀️', 'ليلي 🌙'],
                        selected: controller.themeIndex,
                        onChanged: controller.setThemeIndex,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. الإعدادات الافتراضية للمهام الجديدة
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune_rounded, color: cs.primary),
                        const SizedBox(width: 8),
                        Text('الإعدادات الافتراضية للمهام', style: AppFonts.heading),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('وقت التذكير الاستباقي الافتراضي:', style: AppFonts.subheading),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<int>(
                        value: Fmt.remindOptions
                                .containsKey(controller.defaultRemind.value)
                            ? controller.defaultRemind.value
                            : 10,
                        items: Fmt.remindOptions.entries
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e.key,
                                child: Text(e.value, style: AppFonts.body),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.setDefaultRemind(v);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('الأولوية الافتراضية:', style: AppFonts.subheading),
                    const SizedBox(height: 8),
                    Obx(
                      () => PillToggle(
                        items: const ['عادية 🟢', 'متوسطة 🟠', 'قصوى 🔴'],
                        selected: controller.defaultPriority.value,
                        onChanged: controller.setDefaultPriority,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. لوحة فحص وتشخيص الإشعارات الشاملة
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active_rounded,
                            color: cs.primary),
                        const SizedBox(width: 8),
                        Text('مركز الإشعارات والتنبيهات', style: AppFonts.heading),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('تفعيل الصوت المخصص (notify.wav)',
                            style: AppFonts.subheading),
                        subtitle: Text(
                          'تشغيل النغمة المخصصة مع الاهتزاز عند حلول الموعد',
                          style: AppFonts.small.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                        value: controller.soundEnabled.value,
                        onChanged: controller.toggleSound,
                      ),
                    ),
                    const Divider(height: 20),
                    Obx(
                      () => Column(
                        children: [
                          _StatusRow(
                            label: 'صلاحية إرسال الإشعارات',
                            ok: controller.notificationsGranted.value,
                          ),
                          const SizedBox(height: 8),
                          _StatusRow(
                            label: 'صلاحية المنبه الدقيق (Exact Alarms)',
                            ok: controller.exactAlarmsGranted.value,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الإشعارات المجدولة حالياً في النظام:',
                                  style: AppFonts.body),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${controller.pendingCount.value} إشعار نشط',
                                  style: AppFonts.small.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: controller.testNotification,
                            icon: const Icon(Icons.notifications_rounded),
                            label: const Text('إرسال إشعار تجريبي الآن'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: controller.requestPermissionsAgain,
                          child: const Text('تحديث الصلاحيات'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ok;

  const _StatusRow({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.warning;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppFonts.body),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                ok ? 'مفعّلة' : 'تحتاج تفعيل',
                style: AppFonts.caption.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
