import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '/global/global_data.dart'; // 导入全局数据类
import 'package:dio/dio.dart'; // 导入 Dio 库
import '/widgets/build_gameType_select_button.dart';

class MyFriendsController extends GetxController {
  String type = '';
  final RxList<dynamic> friends = [].obs; // 好友列表
  final RxList<dynamic> searchFriends = [].obs; // 搜索结果列表
  final RxList<dynamic> requestFriends = [].obs; // 好友申请列表
  final TextEditingController searchController =
      TextEditingController(); // 搜索控制器

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFriends(); // 初始化时获取好友列表
    });
  }

  void getFriends() async {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(), // 显示加载指示器
      ),
      barrierDismissible: false, // 禁止用户点击背景关闭对话框
    );
    print(GlobalData.userInfo['friends']);
    var dio = Dio();
    var params = {
      'friends': GlobalData.userInfo['friends'], // 好友列表
      'requestFriends': GlobalData.userInfo['requestFriends'], // 好友申请列表
    };
    try {
      final res = await dio.post(
        '${GlobalData.url}/GetFriends',
        data: params, // 发送请求参数
      );
      if (res.data['code'] == 0) {
        Get.back(); // 关闭对话框

        for (var friend in res.data['data']) {
          if (GlobalData.userInfo['friends'].contains(friend['accountId'])) {
            friends.add(friend); // 添加好友到列表中
          } else {
            requestFriends.add(friend); // 添加好友到列表中
          }
        }

        print(friends); // 打印好友列表
        print(requestFriends);  // 打印好友申请列表
      } else {
        print(res.data);
        Get.back(); // 关闭对话框
        Get.snackbar(
          '错误',
          res.data['msg'],
          snackPosition: SnackPosition.TOP, // 显示在底部
        );
      }
    } catch (e) {
      Get.back(); // 关闭对话框
      print(e); // 打印错误信息
      Get.snackbar(
        '错误',
        '获取好友列表失败',
        snackPosition: SnackPosition.TOP, // 显示在底部
      ); // 显示错误提示
    }
  }

  void invite({required String accountId}) {
    if (type != '') {
      Get.toNamed(
        '/ChineseChessBoard',
        arguments: {'type': type, 'accountId': accountId},
      );
    } else {
      Get.dialog(
        Column(
          children: [
            GameTypeSelectButton(
              gameType: '象棋',
              onPressed: () {
                Get.back(); // 关闭对话框
                Get.toNamed(
                  '/ChineseChessBoard',
                  arguments: {'type': '象棋', 'accountId': accountId},
                );
              },
            ),
            GameTypeSelectButton(
              gameType: '围棋',
              onPressed: () {
                Get.back(); // 关闭对话框
                Get.toNamed(
                  // '/GoBoard',
                  '',
                  arguments: {'type': '围棋', 'accountId': accountId},
                );
              },
            ),
            GameTypeSelectButton(
              gameType: '军棋',
              onPressed: () {
                Get.back(); // 关闭对话框
                Get.toNamed(
                  // '/MilitaryBoard',
                  '',
                  arguments: {'type': '军棋', 'accountId': accountId},
                );
              },
            ),
            GameTypeSelectButton(
              gameType: '五子',
              onPressed: () {
                Get.back(); // 关闭对话框
                Get.toNamed(
                  // '/FirBoard',
                  '',
                  arguments: {'type': '五子', 'accountId': accountId},
                );
              },
            ),
          ],
        ),
        barrierColor: Colors.transparent,
        barrierDismissible: true,
      );
    }
  }

  void request({required String accountId}) {}

  void accept({required String accountId}) {}

  void reject({required String accountId}) {}
}
