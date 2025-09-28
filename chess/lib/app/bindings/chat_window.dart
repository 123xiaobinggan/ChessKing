import '/pages/ChatWindow/chat_window_controller.dart';
import 'package:get/get.dart';

class ChatWindowBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatWindowController>(
      () => ChatWindowController(),
      fenix: true,
    );
  }
}
