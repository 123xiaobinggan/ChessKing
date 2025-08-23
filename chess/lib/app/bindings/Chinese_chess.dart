import 'package:get/get.dart';
import '/pages/ChineseChess/Chinese_chess_controller.dart';



class ChineseChessBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChineseChessController>(() => ChineseChessController());
  }
}