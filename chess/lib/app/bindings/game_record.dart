import 'package:get/get.dart';
import '/pages/GameRecord/game_record_controller.dart';


class GameRecordBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameRecordController>(() => GameRecordController());
  }
}