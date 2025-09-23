import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '/global/global_data.dart';
import '/pages/Tabbar/tabbar_controller.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final accountIdController = TextEditingController(); // 账号输入框控制器
  final userNameController = TextEditingController(); // 用户名输入框控制器
  final passwordController = TextEditingController(); // 密码输入框控制器

  void register() async {
    String accountId = accountIdController.text; // 获取账号输入框的值
    String username = userNameController.text; // 获取用户名输入框的值
    String password = passwordController.text; // 获取密码输入框的值
    print('账号：$accountId，用户名：$username，密码：$password'); // 打印账号、用户名和密码
    GetStorage().remove('accountId');
    GetStorage().remove('password');
    GetStorage().write('accountId', accountId);
    GetStorage().write('password', password);
    final dio = Dio(); // 创建Dio实例
    final Map<String, dynamic> params = {
      // 构造请求参数
      'accountId': accountId, // 账号
      'username': username, // 用户名
      'password': password, // 密码
      'login': false, // 注册标志
      'rid': GlobalData.rid, // 设备ID
    };

    Get.dialog(
      const Center(child: CircularProgressIndicator()), // 显示加载指示器
      barrierDismissible: false, // 禁止用户关闭对话框
    );

    try {
      final response = await dio.post(
        '${GlobalData.url}/Login_Register', // 请求URL
        data: params, // 请求参数
        options: Options(headers: {'Content-Type': 'application/json'}), // 请求头
      );
      print(
        'Response: ${response.data['code']}, ${response.data['code'] == 0}', // 打印响应结果
      );
      if (response.data['code'] == 0) {
        GlobalData.isLoggedIn = true;
        GlobalData.userInfo = RxMap<String, dynamic>(response.data['data']);
        resolveIp();
        Get.back(); // 关闭对话框
        Get.snackbar(
          // 显示成功提示
          '注册成功', // 标题
          '欢迎来到新世界，${GlobalData.userInfo['username']}', // 内容
          snackPosition: SnackPosition.TOP, // 显示位置
        );
        if (Get.isRegistered<TabbarController>()) {
          Get.find<TabbarController>().changeIndex(0);
        } else {
          Get.toNamed('/Tabbar'); // 跳转到Tabbar页面
        }
        GlobalData.socketService.initSocket();
        Get.offNamed('/Tabbar');
      } else {
        Get.back(); // 关闭对话框
        Get.snackbar(
          // 显示失败提示
          '注册失败', // 标题
          response.data['msg'], // 内容
          snackPosition: SnackPosition.TOP, // 显示位置
        );
      }
    } catch (e) {
      Get.back();
      // 捕获异常
      Get.snackbar(
        // 显示错误提示
        '注册失败', // 标题
        '网络错误', // 内容
        snackPosition: SnackPosition.TOP, // 显示位置
      );
    }
  }

  void resolveIp() async {
    const host =
        "https://ipcity.market.alicloudapi.com"; // 请求地址 支持http 和 https 及 WEBSOCKET
    const path = "/ip/city/query"; // 后缀
    const appCode = "1dc84a4fe7fc40238d1a17ad665c59d3";
    // 构建查询参数
    String querys = 'ip=${GlobalData.userInfo['ip']}&coordsys=WGS84';
    String urlSend = '$host$path?$querys'; // 拼接完整请求链接
    print('urlSend, $urlSend');
    var dio = Dio(); // 初始化dio对象
    try {
      final res = await dio.get(
        urlSend, // 发送请求参数
        options: Options(
          headers: {
            'Authorization': 'APPCODE $appCode', // 鉴权信息
          },
        ),
      );
      print('res.data, ${res.data}');
      if (res.statusCode == 200) {
        if (res.data['code'] == 200) {
          String city = '未知';
          if (res.data['data']['result']['city']!='') {
            city = res.data['data']['result']['city'];
          } else if (res.data['data']['result']['prov']!='') {
            city = res.data['data']['result']['province'];
          } else if (res.data['data']['result']['country']!='') {
            city = res.data['data']['result']['country'];
          } else if (res.data['data']['result']['continuent']!='') {
            city = res.data['data']['result']['continent'];
          }
          GlobalData.userInfo['ip'] = city;
          print('city, $city');
        }
      }
    } catch (e) {
      print(e); // 打印错误信息
      GlobalData.userInfo['ip'] = '未知';
    }
  }

  @override
  void onClose() {
    accountIdController.dispose(); // 释放账号输入框控制器
    userNameController.dispose(); // 释放用户名输入框控制器
    passwordController.dispose(); // 释放密码输入框控制器
    super.onClose(); // 调用父类方法
  }
}
