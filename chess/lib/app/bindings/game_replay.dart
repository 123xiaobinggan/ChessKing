import 'package:get/get.dart';
import '/pages/GameReplay/game_replay_controller.dart';


class GameReplayBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameReplayController>(() => GameReplayController());
  }
}