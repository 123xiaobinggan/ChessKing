import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_installer/app_installer.dart';
import 'package:path_provider/path_provider.dart';

class UpdateController extends GetxService {
  final progress = 0.0.obs; // 下载进度
  final isDownloading = false.obs;

  /// 开始下载并安装
  Future<void> downloadAndInstallApk(String url) async {
    if (isDownloading.value) return; // 避免重复下载

    isDownloading.value = true;
    progress.value = 0.0;

    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      Get.snackbar("错误", "无法获取存储目录");
      isDownloading.value = false;
      return;
    }
    String savePath = "${dir.path}/update.apk";

    Dio dio = Dio();

    // 显示进度弹窗
    if (!Get.isDialogOpen!) {
      Get.dialog(
        Obx(() => AlertDialog(
              title: const Text('正在下载更新\n加速器更快',
                  textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress.value),
                  const SizedBox(height: 12),
                  Text("${(progress.value * 100).toStringAsFixed(0)}%"),
                ],
              ),
            )),
        barrierDismissible: false,
      );
    }

    try {
      final res = await dio.download(
        url,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            progress.value = count / total;
          }
        },
      );

      if (res.statusCode == 200) {
        // 下载完成 → 关闭弹窗
        if (Get.isDialogOpen!) Get.back();

        // 安装 apk
        await AppInstaller.installApk(savePath);
      } else {
        _showRetryDialog(url);
      }
    } catch (e) {
      print("下载失败: $e");
      _showRetryDialog(url);
    } finally {
      isDownloading.value = false;
    }
  }

  void _showRetryDialog(String url) {
    if (Get.isDialogOpen!) Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text('下载失败'),
        content: const Text('请检查网络连接或加速器是否开启'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消下载'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              downloadAndInstallApk(url); // 重试
            },
            child: const Text('重新下载'),
          ),
        ],
      ),
    );
  }
}
