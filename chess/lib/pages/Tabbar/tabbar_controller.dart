import 'package:get/get.dart';

class TabbarController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onReady() {
    currentIndex.value = 0;
    super.onReady();
  }
}