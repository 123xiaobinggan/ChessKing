import '/pages/ChineseChessBoard/Chinese_chess_board_controller.dart';
import 'package:get/get.dart';

class ChineseChessBoardBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChineseChessBoardController());
  }
}
