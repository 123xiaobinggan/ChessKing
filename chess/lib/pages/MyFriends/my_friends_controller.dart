import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '/global/global_data.dart'; // 导入全局数据类
import 'package:dio/dio.dart'; // 导入 Dio 库
import '/widgets/build_gameType_select_button.dart';
import '/widgets/show_message_dialog.dart'; // 导入消息对话框组件
import '/widgets/build_select_button.dart'; // 导入选择按钮组件

class MyFriendsController extends GetxController {
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
            print(friend);
            requestFriends.add(friend); // 添加好友到列表中
          }
        }

        print('friends:$friends'); // 打印好友列表
        print('requestFriends:$requestFriends'); // 打印好友申请列表
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
    Get.dialog(
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameTypeSelectButton(
              gameType: '象棋',
              onPressed: () {
                Get.back(); // 关闭对话框
                Get.dialog(
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildSelectButton(
                          " 5 分钟场",
                          5,
                          onTap: () {
                            Get.toNamed(
                              '/ChineseChessBoard',
                              parameters: {
                                'type': "ChineseChessWithFriends",
                                'accountId': accountId,
                                'gameTime': (5 * 60).toString(),
                                "stepTime": 15.toString(),
                              },
                            );
                          },
                        ),
                        buildSelectButton(
                          "10 分钟场",
                          10,
                          onTap: () {
                            Get.toNamed(
                              '/ChineseChessBoard',
                              parameters: {
                                'type': "ChineseChessWithFriends",
                                'accountId': accountId,
                                'gameTime': (10 * 60).toString(),
                                "stepTime": 30.toString(),
                              },
                            );
                          },
                        ),
                        buildSelectButton(
                          "15 分钟场",
                          15,
                          onTap: () {
                            Get.toNamed(
                              '/ChineseChessBoard',
                              parameters: {
                                'type': "ChineseChessWithFriends",
                                'accountId': accountId,
                                'gameTime': (15 * 60).toString(),
                                "stepTime": 60.toString(),
                              },
                            );
                          },
                        ),
                        buildSelectButton(
                          "20 分钟场",
                          20,
                          onTap: () {
                            Get.toNamed(
                              '/ChineseChessBoard',
                              parameters: {
                                'type': "ChineseChessWithFriends",
                                'accountId': accountId,
                                'gameTime': (20 * 60).toString(),
                                "stepTime": 60.toString(),
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  barrierDismissible: true,
                  barrierColor: Colors.transparent,
                );
              },
            ),
            GameTypeSelectButton(
              gameType: '围棋',
              onPressed: () {
                Get.back(); // 关闭对话框
                // Get.toNamed(
                //   // '/GoBoard',
                //   '',
                //   parameters: {'type': '围棋', 'accountId': accountId},
                // );
              },
            ),
            GameTypeSelectButton(
              gameType: '军棋',
              onPressed: () {
                Get.back(); // 关闭对话框
                // Get.toNamed(
                //   // '/MilitaryBoard',
                //   '',
                //   parameters: {'type': '军棋', 'accountId': accountId},
                // );
              },
            ),
            GameTypeSelectButton(
              gameType: '五子',
              onPressed: () {
                Get.back(); // 关闭对话框
                // Get.toNamed(
                //   // '/FirBoard',
                //   '',
                //   parameters: {'type': '五子', 'accountId': accountId},
                // );
              },
            ),
          ],
        ),
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: true,
    );
  }

  void delete({required String accountId}) async {
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'myAccountId': GlobalData.userInfo['accountId'], // 我的账号ID
      'opponentAccountId': accountId, // 对方账号ID
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/DeleteFriends', // 发送删除好友请求
        data: params, // 发送请求参数
        options: Options(
          contentType: 'application/json', // 设置请求头为 JSON 格式
        ),
      );
      if (response.data['code'] == 0) {
        Get.dialog(
          ShowMessageDialog(content: '已删除好友'), // 显示消息对话框
        ); // 显示错误提示
        friends.removeWhere(
          (friend) => friend['accountId'] == accountId,
        ); // 从列表中删除好友
        GlobalData.userInfo['friends'].removeWhere(
          (friend) => friend == accountId,
        ); // 从全局数据中删除好友\
      } else {
        Get.dialog(
          ShowMessageDialog(content: response.data['msg']), // 显示消息对话框
        ); // 显示错误提示
      }
      Future.delayed(
        Duration(seconds: 1),
        () => {
          Get.back(), // 关闭对话框
        },
      );
    } catch (e) {
      print('e,$e');
    }
  }

  void request({required String accountId}) async {
    print('requestFriends');
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'myAccountId': GlobalData.userInfo['accountId'],
      'opponentAccountId': accountId,
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/RequestFriends',
        data: params, // 发送请求参数
      ); // 发送好友申请请求
      if (response.data['code'] == 0) {
        Get.dialog(
          ShowMessageDialog(content: '已发送申请'), // 显示消息对话框
        );
      } else {
        Get.dialog(
          ShowMessageDialog(content: response.data['msg']), // 显示消息对话框
        ); // 显示错误提示
      }
      Future.delayed(
        Duration(seconds: 1),
        () => {
          Get.back(), // 关闭对话框
        },
      );
    } catch (e) {
      print('e,$e');
      Get.dialog(
        ShowMessageDialog(content: '发送申请失败'), // 显示消息对话框
      ); // 显示错误提示
      Future.delayed(
        Duration(seconds: 1),
        () => {
          Get.back(), // 关闭对话框
        },
      );
    }
  }

  void accept({required String accountId}) async {
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'myAccountId': GlobalData.userInfo['accountId'], // 我的账号ID
      'opponentAccountId': accountId, // 对方账号ID
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/AcceptFriends', // 发送好友申请请求
        data: params, // 发送请求参数
        options: Options(
          contentType: 'application/json', // 设置请求头为 JSON 格式
        ),
      );
      if (response.data['code'] == 0) {
        Get.dialog(
          ShowMessageDialog(content: '已同意申请'), // 显示消息对话框
        ); // 显示错误提示
      } else {
        Get.dialog(
          ShowMessageDialog(content: response.data['msg']), // 显示消息对话框
        ); // 显示错误提示
      }
      GlobalData.userInfo['friends'].add(accountId); // 添加好友到全局数据中
      requestFriends.removeWhere(
        (friend) => friend['accountId'] == accountId,
      ); // 从列表中删除好友
      GlobalData.userInfo['requestFriends'].removeWhere(
        (friend) => friend == accountId,
      );
      Future.delayed(
        Duration(seconds: 1),
        () => {
          Get.back(), // 关闭对话框
        },
      );
    } catch (e) {
      print('e,$e');
    }
  }

  void reject({required String accountId}) async {
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'myAccountId': GlobalData.userInfo['accountId'], // 我的账号ID
      'opponentAccountId': accountId, // 对方账号ID
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/RejectFriends', // 发送好友申请请求
        data: params, // 发送请求参数
        options: Options(
          contentType: 'application/json', // 设置请求头为 JSON 格式
        ),
      );
      if (response.data['code'] == 0) {
        Get.dialog(
          ShowMessageDialog(content: '已拒绝申请'), // 显示消息对话框
        ); // 显示错误提示
      } else {
        Get.dialog(
          ShowMessageDialog(content: response.data['msg']), // 显示消息对话框
        ); // 显示错误提示
      }
      Future.delayed(
        Duration(seconds: 1),
        () => {
          Get.back(), // 关闭对话框
        },
      );
    } catch (e) {
      print('e,$e');
    }
  }

  void search() async {
    print('search');
    final keyword = searchController.text.trim(); // 获取搜索关键字
    if (keyword.isEmpty) {
      searchFriends.clear(); // 如果关键字为空，清空搜索结果列表
      return;
    }
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'keyword': keyword, // 搜索关键字
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/SearchFriends',
        data: params,
        options: Options(
          contentType: 'application/json', // 设置请求头为 JSON 格式
        ),
      ); // 发送搜索请求
      print(response.data);
      if (response.data['code'] == 0) {
        print(response.data['data']);
        searchFriends.clear(); // 清空搜索结果列表
        for (var friend in response.data['data']) {
          print(friend);
          if (friend['accountId'] != GlobalData.userInfo['accountId']) {
            searchFriends.add(friend); // 添加搜索结果到列表中
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
