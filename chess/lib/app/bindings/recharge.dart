import 'package:get/get.dart';
import '../../pages/Recharge/recharge_controller.dart';


class RechargeBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargeController>(() => RechargeController());
  }

}