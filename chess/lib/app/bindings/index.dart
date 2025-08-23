import 'package:get/get.dart';
import '../../pages/index/index_controller.dart';

class IndexBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndexController>(() => IndexController());
  }
}