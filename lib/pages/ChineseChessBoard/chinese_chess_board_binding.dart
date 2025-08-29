import 'package:get/get.dart';
import 'Chinese_chess_board_controller.dart';

class ChineseChessBoardBinding implements Bindings {
  @override
  void dependencies() {
    // 不缓存，每次进入都重新创建
    Get.lazyPut<ChineseChessBoardController>(
      () => ChineseChessBoardController(),
      fenix: true,          // 允许再次创建
    );
  }
}
