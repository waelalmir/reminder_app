import 'package:get/get.dart';

import '../controller/add_task_controller.dart';
import '../controller/home_controller.dart';
import '../controller/settings_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => HomeController());
}

class AddTaskBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AddTaskController());
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SettingsController());
}
