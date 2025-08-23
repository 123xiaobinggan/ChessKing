import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_installer/app_installer.dart';
import 'package:get/get.dart';

class AppUpdater {
  /// 下载 APK 并安装
  static Future<void> downloadAndInstallApk(String apkUrl) async {
    try {
      // 获取临时目录
      Directory dir = await getTemporaryDirectory();
      String savePath = "${dir.path}/update.apk";

      // 进度变量
      RxDouble progress = 0.0.obs;

      // 弹窗显示进度条
      Get.dialog(
        PopScope(
          canPop: false,
          child: Obx(() {
            return AlertDialog(
              title: Text("正在下载更新"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress.value),
                  SizedBox(height: 12),
                  Text("${(progress.value * 100).toStringAsFixed(0)}%"),
                ],
              ),
            );
          }),
        ),
        barrierDismissible: false,
      );

      // 开始下载
      Dio dio = Dio();
      await dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            progress.value = count / total;
          }
        },
      );

      // 下载完成，关闭弹窗
      Get.back();

      // 安装 APK
      if (await File(savePath).exists()) {
        await AppInstaller.installApk(savePath);
      } else {
        Get.snackbar("安装失败", "APK 文件不存在",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("更新失败", "下载或安装出错：$e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
