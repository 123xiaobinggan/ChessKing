import 'package:get/get.dart';
import '/global/global_data.dart';
import 'package:flutter/services.dart';
import '../../widgets/show_message_dialog.dart';
import 'package:flutter/material.dart';

class VersionController extends GetxController {
  final String version = "${GlobalData.version!['version']}";
  final List<dynamic> changelog = GlobalData.version!['changeLog'];
  bool isUpToDate = false;

  @override
  void onInit() async {
    super.onInit();
    isUpToDate = version == GlobalData.packageInfo.version;
  }

  void downloadUpdate() async {
    // 获取下载链接
    final url = GlobalData.downloadUrl;
    await Clipboard.setData(ClipboardData(text: url));
    Get.dialog(
      ShowMessageDialog(content: "下载链接已复制到剪贴板\n您可以在浏览器中打开它\n下载可能需要打开加速器"),
      barrierDismissible: true,
      barrierColor: Colors.transparent,
    );
    Future.delayed(const Duration(milliseconds: 2000), () {
      Get.back();
    });
  }
}
