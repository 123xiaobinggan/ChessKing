import 'package:get/get.dart';
import '../../pages/Enter/Register/register_controller.dart';

class RegisterBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterController()); // 懒加载 LoginController
  }
}
