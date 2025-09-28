import 'package:get/get.dart';
import '../../pages/Conversation/conversation_controller.dart';

class ConversationsBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConversationsController()); // 懒加载 MyFriendsController
  }
}
