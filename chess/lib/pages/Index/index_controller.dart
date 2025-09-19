import 'package:get/get.dart';

class IndexController extends GetxController {
  RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('init');
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
