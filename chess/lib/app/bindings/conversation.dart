import 'package:get/get.dart';
import '../../pages/Conversation/conversation_controller.dart';

class ConversationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConversationsController());
  }
}