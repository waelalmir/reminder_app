import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../core/utils/formatters.dart';
import '../data/models/category_model.dart';
import '../routes.dart';
import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/task_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openEditor(),
        icon: const Icon(Icons.add_task_rounded),
        label: Text(
          'مهمة جديدة',
          style: AppFonts.subheading.copyWith(color: Colors.white),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. بطاقة الترحيب والإحصائيات العلوية
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _HeaderDashboard(controller: controller),
              ),

              // 2. شريط البحث السريع
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Obx(
                  () => TextField(
                    controller: controller.searchController,
                    onChanged: controller.setSearch,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مهمة، مشوار، أو ملاحظة...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: cs.primary,
                      ),
                      suffixIcon: controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              onPressed: controller.clearSearch,
                              icon: const Icon(Icons.close_rounded, size: 20),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // 3. شريط تصفية التصنيفات الأفقي
              SizedBox(
                height: 44,
                child: Obx(() {
                  final selectedCat = controller.selectedCategory.value;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: taskCategories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        final active = selectedCat == -1;
                        return _CategoryChip(
                          label: 'كل الفئات',
                          icon: Icons.grid_view_rounded,
                          color: cs.primary,
                          active: active,
                          onTap: () => controller.selectCategory(-1),
                        );
                      }
                      final cat = taskCategories[index - 1];
                      final active = selectedCat == index - 1;
                      return _CategoryChip(
                        label: cat.name,
                        icon: cat.icon,
                        color: cat.color,
                        active: active,
                        onTap: () => controller.selectCategory(index - 1),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 8),

              // 4. تبويبات الحالة (الكل / اليوم / المتأخرة / المكتملة)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final current = controller.filter.value;
                  final counts = [
                    controller.pending,
                    controller.todayCount,
                    controller.lateCount,
                    controller.completedCount,
                  ];
                  return Row(
                    children: List.generate(
                      HomeController.filters.length,
                      (i) {
                        final active = current == i;
                        final isLateTab = i == 2 && counts[i] > 0;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: i < HomeController.filters.length - 1 ? 6 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => controller.filter.value = i,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? (isLateTab
                                          ? AppColors.danger
                                          : cs.primary)
                                      : cs.surface.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: active
                                        ? Colors.transparent
                                        : cs.outlineVariant
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        HomeController.filters[i],
                                        style: AppFonts.small.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: active
                                              ? Colors.white
                                              : cs.onSurface
                                                  .withValues(alpha: 0.75),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? Colors.white
                                                  .withValues(alpha: 0.22)
                                              : (isLateTab
                                                  ? AppColors.danger
                                                      .withValues(alpha: 0.15)
                                                  : cs.primary
                                                      .withValues(alpha: 0.1)),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${counts[i]}',
                                          style: AppFonts.caption.copyWith(
                                            color: active
                                                ? Colors.white
                                                : (isLateTab
                                                    ? AppColors.danger
                                                    : cs.primary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),

              // 5. قائمة المهام
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = controller.shown;
                  if (list.isEmpty) {
                    return _EmptyState(
                      filterIndex: controller.filter.value,
                      hasSearch: controller.searchQuery.value.isNotEmpty ||
                          controller.selectedCategory.value >= 0,
                      onResetFilters: () {
                        controller.clearSearch();
                        controller.selectedCategory.value = -1;
                      },
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final t = list[i];
                      return Dismissible(
                        key: ValueKey('task_${t.id}_${t.done}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => controller.remove(t),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'حذف المهمة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                        child: TaskCard(
                          task: t,
                          onToggle: () => controller.toggle(t),
                          onTap: () => controller.openEditor(t),
                          onPin: () => controller.togglePin(t),
                          onToggleSubtask: (subIdx) =>
                              controller.toggleSubtask(t, subIdx),
                          onSnooze: (dur) => controller.snoozeTask(t, dur),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderDashboard extends StatelessWidget {
  final HomeController controller;
  const _HeaderDashboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.headerGradient,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.seed.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        final rate = controller.completionRate;
        final percent = (rate * 100).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Fmt.greeting(),
                        style: AppFonts.small.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'مُذكّري الذكي',
                            style: AppFonts.display.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              Fmt.fullDate(DateTime.now()),
                              style: AppFonts.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.toNamed(Routes.settings),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatBadge(
                  label: 'قيد التنفيذ',
                  value: '${controller.pending}',
                  icon: Icons.pending_actions_rounded,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'مهام اليوم',
                  value: '${controller.todayCount}',
                  icon: Icons.today_rounded,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'نسبة الإنجاز',
                  value: '$percent%',
                  icon: Icons.verified_rounded,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppFonts.subheading.copyWith(
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : cs.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.small.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? Colors.white : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int filterIndex;
  final bool hasSearch;
  final VoidCallback onResetFilters;

  const _EmptyState({
    required this.filterIndex,
    required this.hasSearch,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, title, subtitle) = switch (filterIndex) {
      1 => (
          Icons.wb_sunny_rounded,
          'لا توجد مهام مجدولة لليوم',
          'استمتع بيومك أو أضف مشواراً جديداً من الزر بالأسفل'
        ),
      2 => (
          Icons.task_alt_rounded,
          'رائع! لا توجد أي مهام متأخرة',
          'أنت ملتزم بجميع مواعيدك بشكل ممتاز'
        ),
      3 => (
          Icons.inbox_rounded,
          'لا توجد مهام مكتملة بعد',
          'عند إنجاز أي مهمة ستظهر هنا لمراجعتها'
        ),
      _ => (
          Icons.auto_awesome_rounded,
          hasSearch ? 'لا توجد نتائج مطابقة للبحث' : 'قائمة مهامك فارغة الآن',
          hasSearch
              ? 'جرّب تغيير كلمة البحث أو عرض كل الفئات'
              : 'ابدأ بإضافة مهامك ومشاويرك وسيتولى التطبيق تذكيرك بها'
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 42, color: cs.primary),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.heading,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppFonts.body.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (hasSearch) ...[
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة ضبط البحث والفلاتر'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
