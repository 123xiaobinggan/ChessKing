import '/pages/level/level_controller.dart';
import 'package:get/get.dart';

class LevelBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelController>(() => LevelController());
  }
}