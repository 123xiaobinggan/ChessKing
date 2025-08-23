import '/pages/ChineseChessMatch/chinese_chess_match_controller.dart';
import 'package:get/get.dart';


class ChineseChessMatchBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChineseChessMatchController>(() => ChineseChessMatchController());
  }
}