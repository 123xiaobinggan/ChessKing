import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '/global/global_data.dart';
import 'package:dio/dio.dart';
import '/pages/Tabbar/tabbar_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../../../api/pushManager.dart';
import 'dart:math';

class LoginController extends GetxController {
  final accountIdController = TextEditingController();
  final passwordController = TextEditingController();
  final _storage = GetStorage();
  static const List<String> sayings = [
    "落子无悔大丈夫",
    "棋路漫漫 有你相伴",
    "棋场即战场",
    "宁失一子 不失一先",
    "乾坤未定 你我皆是黑马",
    "一着不慎 满盘皆输",
    "以棋会友",
    "到乡翻似烂柯人",
    "相见恨晚 旗鼓相当",
    "一鼓作气 先发制人",
    "君子一言 快马一鞭",
    "兵者 诡道也",
    "罗袜生尘 凌波微步",
    "月之皎兮 佼人僚兮",
    "闲敲棋子落灯花",
    "日日思君不见君",
    "白露横江 水光接天",
    "雪压围棋石 风吹饮酒楼",
    "玉作弹棋局 中心亦不平",
    "恃强斯有失 守分固无侵",
    "人间与世远 鸟语知境静",
    "十分潋滟君休赤",
    "易醉扶头酒 难逢敌手棋",
    "诗酒琴棋客 风花雪月天",
    "高田如楼梯,平田如棋局",
    "一局残棋见六朝",
    "雪拥蓝关马不前",
    "将军置酒饮归客",
    "男儿何不带吴钩",
    "谈笑间 樯橹灰飞烟灭",
    "实者虚之 虚者实之",
  ];

  static final List<List<Color>> gradients = [
    [Color(0xFFFFD700), Color(0xFFFF8C00)],
    [Color(0xFFFFDDE1), Color(0xFFFEC8D8)],
    [Color(0xFFFF758C), Color(0xFFFF7EB3)],
    [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
    [Color(0xFFB2F7EF), Color(0xFF82EEDD)],
    [Color(0xFFC3AED6), Color(0xFF736CED)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF9966FF), Color(0xFF99CCFF)],
    [Color(0xFF3399FF), Color(0xFF99CCFF)],
    [Color(0xFF66CCFF), Color(0xFF99CCFF)],
    [Color(0xFF6699FF), Color(0xFF99CCFF)],
  ];

  static final List<String> fontFamilies = [
    "ZhiMangXing-Regular",
    "MaShanZheng-Regular",
    "YunFengJingLong",
    "XiaoJiaoWenXun",
    "XiaWuZhenKai",
    "SanJi",
    "QianDu",
    "LinHaiDiShu",
  ];

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
    if (accountIdController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        GlobalData.userInfo['accountId'] == '') {
      login();
    }
  }

  static int changeFont() {
    int fontIndex =  Random().nextInt(fontFamilies.length);
    print('fontIndex,$fontIndex');
    return fontIndex;
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
      'rid': GlobalData.rid,
    };
    Future.microtask(() {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
    });

    print('${GlobalData.url}/Login_Register');
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
        GlobalData.isLoggedIn = true;
        PushManager.handlePendingAfterLogin();
        Get.back();
        GlobalData.userInfo = RxMap<String, dynamic>(response.data['data']);
        print(GlobalData.userInfo);
        Get.snackbar(
          '登录成功',
          '欢迎回来，${GlobalData.userInfo['username']}',
          snackPosition: SnackPosition.TOP,
        );
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

  @override
  void onClose() {
    accountIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
