import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/Enter/Login/login.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart'; // 导入 Dio 库
import '/global/global_data.dart'; // 导入全局数据类
import 'install.dart';

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
          bool needUpdate = await checkUpdate();
          if (!needUpdate) {
            // 没有新版本才进入登录页
            Get.off(
              () => Login(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 800),
            );
          }
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

  Future<bool> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    try {
      Dio dio = Dio();
      final response = await dio.get('${GlobalData.url}/GetVersion');
      String latestVersion = response.data['version'];

      if (currentVersion != latestVersion) {
        // 弹窗提示
        Get.dialog(
          AlertDialog(
            title: Text('版本更新'),
            content: Text('发现新版本：$latestVersion\n当前版本：$currentVersion'),
            actions: [
              TextButton(
                onPressed: () async {
                  Get.back(); // 关闭弹窗
                  await AppUpdater.downloadAndInstallApk(
                    "https://你的服务器地址/your_app.apk",
                  );
                },
                child: Text('去更新'),
              ),
            ],
          ),
        );

        return true; // 表示有新版本
      }
    } catch (e) {
      print("获取版本失败: $e");
    }

    return false; // 没有新版本
  }
}
