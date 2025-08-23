import 'package:get/get.dart';
import '/pages/Edit/edit_controller.dart';



class EditBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditController>(() => EditController());
  }
}