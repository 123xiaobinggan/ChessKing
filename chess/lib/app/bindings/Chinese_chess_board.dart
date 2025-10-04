import '/pages/ChineseChessBoard/Chinese_chess_board_controller.dart';
import 'package:get/get.dart';

class ChineseChessBoardBindings implements Bindings {
  final String tag;
  ChineseChessBoardBindings({required this.tag});
  @override
  void dependencies() {
    Get.lazyPut<ChineseChessBoardController>(
      () => ChineseChessBoardController(),
      fenix: true,
      tag:  tag,
    );
  }
}
