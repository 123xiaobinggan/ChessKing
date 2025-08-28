import 'package:get/get.dart';

class GlobalData extends GetxController {
  static var url =
      "https://chess-king-1gvhs90sfc60354d-1358387153.ap-shanghai.app.tcloudbase.com";
  static var userInfo = <String, dynamic>{
    'accountId': '123456',
    'username': '张三',
    'avatar': 'assets/MyInfo/NotLogin.png',
    'description': '孤独求败！',
    'phone': '15659267970',
    'ip': '厦门市',
    'gold': 100,
    'activity': 1120,
    'coupon': 400,
    'friends': ['xiaobinggan'],
    "ChineseChess": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
    "Go": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
    "military": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
    "Fir": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
  }.obs;
  static var rid = '';
  static Map<dynamic, dynamic>? pendingNotification;
  static bool isLoggedIn = false;
}
