import 'package:get/get.dart';
import '../../pages/Tabbar/tabbar_controller.dart';

class TabbarBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabbarController>(() => TabbarController());
  }
}