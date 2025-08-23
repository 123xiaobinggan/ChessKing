import '/pages/ChineseChessRank/Chinese_chess_rank_controller.dart';
import 'package:get/get.dart';

class ChineseChessChallengeBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChineseChessRankController>(() => ChineseChessRankController());
  }
} 