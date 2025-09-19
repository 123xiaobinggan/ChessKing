import 'package:get/get.dart';
import '../../api/pushManager.dart';
import '../../global/global_data.dart';

class TabbarController extends GetxController {
  RxInt currentIndex = 0.obs;


  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onReady() {
    currentIndex.value = 0;
    super.onReady();
    print('ready');
    Future.delayed(Duration.zero, () {
      if (Get.context != null) {
        PushManager.checkAndRequestPermission(Get.context!);
      }
    });

    if (GlobalData.pendingNotification != null) {
      PushManager.handlePendingAfterLogin();
    }
  }
}
