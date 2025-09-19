import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/Enter/Login/login.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart'; // 导入 Dio 库
import '/global/global_data.dart'; // 导入全局数据类
import 'package:app_installer/app_installer.dart'; // 导入 AppInstaller 库

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);

    _controller.forward();

    // 等动画播完后再跳转
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          await checkUpdate();

          Get.off(
            () => Login(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Image.asset("assets/Login/Logo.png", width: 120),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    final completer = Completer<void>();

    try {
      Dio dio = Dio();
      final response = await dio.post('${GlobalData.url}/GetVersion');
      print('response: ${response.data}');
      String latestVersion = response.data['data']['version'];
      String url = response.data['data']['url'];
      print("最新版本: $latestVersion, 当前版本: $currentVersion, 下载地址: $url");

      if (currentVersion != latestVersion) {
        print("需要更新");
        Future.microtask(() {
          Get.dialog(
            AlertDialog(
              title: Text('版本更新'),
              content: Text('发现新版本：$latestVersion\n当前版本：$currentVersion'),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    completer.complete();
                  },
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back();
                    await AppUpdater.downloadAndInstallApk(url);
                    completer.complete();
                  },
                  child: Text('去更新'),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        });
        await completer.future;
      } else {
        completer.complete();
      }
    } catch (e) {
      print("获取版本失败: $e");
      completer.complete();
    }
  }
}

class AppUpdater {
  /// 下载并安装 apk
  static Future<void> downloadAndInstallApk(String url) async {
    final dir = Directory("/storage/emulated/0/Download");
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    String savePath = "${dir.path}/update.apk";
    Dio dio = Dio();

    // 下载进度
    final progress = 0.0.obs;

    // 显示下载进度弹窗
    Get.dialog(
      Obx(
        () => AlertDialog(
          title: Text('正在下载更新\n请打开加速器', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress.value),
              SizedBox(height: 12),
              Text("${(progress.value * 100).toStringAsFixed(0)}%"),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // 执行下载
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
      if (res.statusCode != 200) {
        print("下载失败");
        Get.dialog(
          AlertDialog(
            title: Text('下载失败'),
            content: Text('请检查网络连接或加速器是否开启'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('取消下载'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  downloadAndInstallApk(url);
                },
                child: Text('重新下载'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("下载失败: $e");
      Get.dialog(
        AlertDialog(
          title: Text('下载失败'),
          content: Text('请检查网络连接或加速器是否开启'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('取消下载'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                downloadAndInstallApk(url);
              },
              child: Text('重新下载'),
            ),
          ],
        ),
      );
    }

    // 下载完成，关闭弹窗
    Get.back();

    // 调用系统安装
    try {
      await AppInstaller.installApk(savePath);
    } catch (e) {
      print("安装失败: $e");
    }
  }
}
