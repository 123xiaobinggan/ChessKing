import 'package:get/get.dart';
import '../../pages/MyFriends/my_friends_controller.dart';

class MyFriendsBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyFriendsController()); // 懒加载 MyFriendsController
  }
}
