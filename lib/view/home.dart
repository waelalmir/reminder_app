import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../routes.dart';
import 'widgets/app_background.dart';
import 'widgets/pill_toggle.dart';
import 'widgets/task_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => controller.openEditor(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => PillToggle(
                      items: HomeController.filters,
                      index: controller.filter.value,
                      onChanged: (i) => controller.filter.value = i,
                    )),
              ),
              const SizedBox(height: 12),
              Expanded(child: Obx(() => _list(cs))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        padding: const EdgeInsets.fromLTRB(20, 14, 8, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: AppColors.headerGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.seed.withValues(alpha: .35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                final pending = controller.pending;
                final late = controller.lateCount;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أهلاً بك 👋',
                        style: AppFonts.body.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      pending == 0
                          ? 'لا مهام متبقية، رائع!'
                          : 'لديك $pending مهمة متبقية',
                      style: AppFonts.title.copyWith(color: Colors.white),
                    ),
                    if (late > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$late متأخرة ⚠️',
                            style:
                                AppFonts.small.copyWith(color: Colors.white)),
                      ),
                    ],
                  ],
                );
              }),
            ),
            IconButton(
              onPressed: () => Get.toNamed(Routes.settings),
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
            ),
          ],
        ),
      );

  Widget _list(ColorScheme cs) {
    if (controller.loading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    final list = controller.shown;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded,
                size: 84, color: cs.primary.withValues(alpha: .35)),
            const SizedBox(height: 12),
            Text('لا يوجد شيء هنا',
                style: AppFonts.heading
                    .copyWith(color: cs.onSurface.withValues(alpha: .55))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final t = list[i];
        return Dismissible(
          key: ValueKey(t.id),
          onDismissed: (_) => controller.remove(t),
          background: _dismissBg(cs, Alignment.centerRight),
          secondaryBackground: _dismissBg(cs, Alignment.centerLeft),
          child: TaskCard(
            task: t,
            onTap: () => controller.openEditor(t),
            onToggle: () => controller.toggle(t),
          ),
        );
      },
    );
  }

  Widget _dismissBg(ColorScheme cs, Alignment a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: a,
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
      );
}
