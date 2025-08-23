import 'package:get/get.dart';
import '../../global/global_data.dart';
import 'package:dio/dio.dart';

class MyInfoController extends GetxController {
  
  void logout() {
    // 跳转到登录页面
    Get.offNamed('/Login');
  }

  void onClose() {
    super.onClose();
  }
}
