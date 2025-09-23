import 'package:get/get.dart';
import '/global/global_data.dart';
import 'package:dio/dio.dart';

class MyInfoController extends GetxController {
  void logout() async {
    // 跳转到登录页面
    GlobalData.isLoggedIn = false;
    GlobalData.socketService.dispose();
    Dio dio = Dio();
    try {
      final res = await dio.post(
        GlobalData.url + '/DeleteRid',
        data: {'accountId': GlobalData.userInfo['accountId']},
      );
      if (res.data['code'] == 0) {
        print('删除成功');
      }
    } catch (e) {
      print('e, $e');
    }
    Get.offNamed('/Login');
  }

  void onClose() {
    super.onClose();
  }
}
