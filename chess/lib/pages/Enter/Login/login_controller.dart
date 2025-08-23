import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '/global/global_data.dart';
import 'package:dio/dio.dart';
import '/pages/Tabbar/tabbar_controller.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final accountIdController = TextEditingController();
  final passwordController = TextEditingController();
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    if (_storage.hasData('accountId')) {
      accountIdController.text = _storage.read('accountId');
      print('accountId,${accountIdController.text}');
    }
    if (_storage.hasData('password')) {
      passwordController.text = _storage.read('password');
      print('password,${passwordController.text}');
    }
  }

  void login() async {
    String accountId = accountIdController.text;
    String password = passwordController.text;
    _storage.write('accountId', accountId);
    _storage.write('password', password);
    print('Login: $accountId, $password');

    final dio = Dio();
    final Map<String, dynamic> params = {
      'accountId': accountId,
      'username': '',
      'password': password,
      'login': true,
    };
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final response = await dio.post(
        '${GlobalData.url}/Login_Register',
        data: params,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print(
        'Response: ${response.data['code']}, ${response.data['code'] == 0}',
      );
      if (response.data['code'] == 0) {
        Get.back();
        GlobalData.userInfo = RxMap<String, dynamic>(response.data['data']);
        resolveIp();
        print(GlobalData.userInfo);
        Get.snackbar(
          '登录成功',
          '欢迎回来，${GlobalData.userInfo['username']}',
          snackPosition: SnackPosition.TOP,
        );
        if (Get.isRegistered<TabbarController>()) {
          Get.find<TabbarController>().currentIndex.value = 0;
        } else {
          Get.put(TabbarController());
        }
        Get.offNamed('/Tabbar');
      } else {
        Get.back();
        Get.snackbar(
          '登录失败',
          response.data['msg'],
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (e) {
      Get.back();
      print('Error: $e');
      Get.snackbar('登录失败', '网络错误', snackPosition: SnackPosition.BOTTOM);
      return;
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
          if (res.data['data']['result']['city'] != '') {
            city = res.data['data']['result']['city'];
          } else if (res.data['data']['result']['prov'] != '') {
            city = res.data['data']['result']['province'];
          } else if (res.data['data']['result']['country'] != '') {
            city = res.data['data']['result']['country'];
          } else if (res.data['data']['result']['continuent'] != '') {
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
    accountIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
