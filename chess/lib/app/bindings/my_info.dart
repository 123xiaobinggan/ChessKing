import 'package:get/get.dart';
import '../../pages/MyInfo/my_info_controller.dart';

class MyInfoBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyInfoController>(() => MyInfoController());
  }
}