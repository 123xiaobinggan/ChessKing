import 'package:get/get.dart';
import '../../update_controller.dart';

class UpdateBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateController>(() => UpdateController());
  }
}