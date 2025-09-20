import 'package:get/get.dart';
import '/global/global_data.dart';

class VersionController extends GetxController {
  final String version = "${GlobalData.version!['version']}";
  final List<dynamic> changelog = GlobalData.version!['changeLog'];

  @override
  void onInit() async {
    super.onInit();
  }
}
