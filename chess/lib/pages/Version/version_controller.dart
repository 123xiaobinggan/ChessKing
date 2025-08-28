import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '/global/global_data.dart';
import 'package:dio/dio.dart';

class VersionController extends GetxController {
  final String version = "1.0.1";
  final List<String> changelog = [
    "✨ 新增用户信息编辑功能",
    "🐞 修复部分图片上传失败问题",
    "🚀 优化启动速度",
    "🛠️ 小幅调整界面样式",
  ];

  @override
  void onInit() async {
    super.onInit();
    await getLatestVersion();
  }

  Future<void> getLatestVersion() async {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(), // 显示加载指示器
      ),
      barrierDismissible: false, // 禁止用户点击背景关闭对话框
    );
    Dio dio = Dio();
    try {
      final response = await dio.get('${GlobalData.url}/GetVersion');
      String latestVersion = response.data['data']['version'];
      changelog.clear();
      changelog.addAll(response.data['data']['changelog']);
      print("最新版本: $latestVersion, 当前版本: $version");
    } catch (e) {
      print("获取版本信息失败: $e");
    } finally {
      Get.back(); // 关闭对话框
    }
  }
}
