import 'package:get/get.dart';
import '/global/global_data.dart';

class MyInfoController extends GetxController {
  void logout() {
    // 跳转到登录页面
    GlobalData.isLoggedIn = false;
    Get.offNamed('/Login');
  }

  void onClose() {
    super.onClose();
  }
}
