import 'package:get/get.dart';
import '../../pages/Enter/Login/login_controller.dart';

class LoginBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController()); // 懒加载 LoginController
  }
}
