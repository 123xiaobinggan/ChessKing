import 'package:get/get.dart';
import '/pages/Version/version_controller.dart';

class VersionBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VersionController>(() => VersionController());
  }
}