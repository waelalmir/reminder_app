import 'package:get/get.dart';

import 'binding/app_bindings.dart';
import 'view/add_task.dart';
import 'view/home.dart';
import 'view/settings.dart';

abstract class Routes {
  static const home = '/';
  static const add = '/add';
  static const settings = '/settings';

  static final pages = <GetPage>[
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: add,
      page: () => const AddTaskView(),
      binding: AddTaskBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.leftToRightWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
  ];
}
