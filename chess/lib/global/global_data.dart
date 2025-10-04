import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GlobalData extends GetxController {
  static var url = "http://120.48.156.237:3000";
  // static var url = "{服务器地址}";
  static var socketService;
  static var userInfo = <String, dynamic>{
    'accountId': '',
    'username': '',
    'avatar': 'assets/MyInfo/NotLogin.png',
    'description': '孤独求败！',
    'phone': '15659267970',
    'ip': '厦门市',
    'gold': 100,
    'activity': 1120,
    'coupon': 400,
    'friends': [],
    "ChineseChess": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
    "Go": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
    "military": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
    "Fir": {'level': '1-1', 'total': 0, 'win': 0, 'lose': 0},
  }.obs;
  static var rid = '';
  static Map<dynamic, dynamic>? version;
  static Map<dynamic, dynamic>? pendingNotification;
  static bool isLoggedIn = false;
  static bool isPlaying = false;
  static late PackageInfo packageInfo;
  static String downloadUrl = "";
  static Map<String,bool> friendsOnline = {};
}
