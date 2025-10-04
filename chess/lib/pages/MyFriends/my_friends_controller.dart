import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../widgets/build_personal_info_card.dart';
import '/global/global_data.dart'; // 导入全局数据类
import 'package:dio/dio.dart'; // 导入 Dio 库
import '/widgets/build_gameType_select_button.dart';
import '/widgets/show_message_dialog.dart'; // 导入消息对话框组件
import '/widgets/build_select_button.dart'; // 导入选择按钮组件

class MyFriendsController extends GetxController {
  final RxList<dynamic> friends = [].obs; // 好友列表
  final RxList<dynamic> requestFriends = [].obs; // 好友申请列表
  final RxList<dynamic> notAddFriends = [].obs; // 未添加的好友列表
  final RxList<dynamic> displayList = [].obs; // 搜索结果列表
  final TextEditingController searchController =
      TextEditingController(); // 搜索控制器
  final socketService = GlobalData.socketService;
  StreamSubscription<dynamic>? _receiveFriendsOnlinesubscription;
  StreamSubscription<dynamic>? _receiveFriendsOfflinesubscription;

  @override
  void onInit() async {
    super.onInit();
    socketService.initSocket(); // 初始化 Socket 连接
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getFriends(); // 初始化时获取好友列表
      getNotAddedFriends(); // 初始化时获取未添加的好友列表
    });
    _receiveFriendsOnlinesubscription = socketService.onReceiveFriendsOnline
        .listen((data) {
          print('onReceiveFriendsOnline: $data');
          for (var friend in friends) {
            if (friend['accountId'] == data['accountId']) {
              friend['online'].value = true; // 更新好友在线状态
              break; // 找到后退出循环
            }
          }
        });

    _receiveFriendsOfflinesubscription = socketService.onReceiveFriendsOffline
        .listen((data) {
          print('onReceiveFriendsOffline: $data');
          for (var friend in friends) {
            if (friend['accountId'] == data['accountId']) {
              friend['online'].value = false; // 更新好友在线状态
              break; // 找到后退出循环
            }
          }
        });
  }

  @override
  void onClose() {
    super.onClose();
    searchController.dispose(); // 释放搜索控制器
    _receiveFriendsOnlinesubscription?.cancel(); // 取消订阅
    _receiveFriendsOnlinesubscription = null;
    _receiveFriendsOfflinesubscription?.cancel(); // 取消订阅
    _receiveFriendsOfflinesubscription = null;
  }

  Future<void> getFriends() async {
    var dio = Dio();
    var params = {'accountId': GlobalData.userInfo['accountId']};
    try {
      final res = await dio.post(
        '${GlobalData.url}/GetFriends',
        data: params, // 发送请求参数
      );
      if (res.data['code'] == 0) {
        print('friends: ${res.data['data']['friendsList']}');
        print('requestFriends: ${res.data['data']['requestFriendsList']}');
        for (var friend in res.data['data']['friendsList']) {
          if (friend['accountId'] == GlobalData.userInfo['accountId']) {
            continue; // 如果是自己，则跳过
          }
          if (friends.any(
            (element) => element['accountId'] == friend['accountId'],
          )) {
            continue; // 如果已存在，则跳过
          }
          friends.add(friend); // 添加好友到列表中
        }

        for (var requestFriend in res.data['data']['requestFriendsList']) {
          if (requestFriend['accountId'] == GlobalData.userInfo['accountId']) {
            continue; // 如果是自己，则跳过
          }
          if (requestFriends.any(
            (element) => element['accountId'] == requestFriend['accountId'],
          )) {
            continue; // 如果已存在，则跳过
          }
          requestFriends.add(requestFriend); // 添加好友申请到列表中
        }
        GlobalData.userInfo['friends'].clear();
        GlobalData.userInfo['friends'].addAll(
          friends
              .map(
                (f) => {
                  'accountId': f['accountId'],
                  'username': f['username'],
                  'avatar': f['avatar'],
                },
              )
              .toList(),
        );
        print('friends:$friends'); // 打印好友列表
        print('requestFriends:$requestFriends'); // 打印好友申请列表
      } else {
        print(res.data);
        Get.snackbar(
          '错误',
          res.data['msg'],
          snackPosition: SnackPosition.TOP, // 显示在顶部
        );
      }
    } catch (e) {
      print(e); // 打印错误信息
      Get.snackbar(
        '错误',
        '获取好友列表失败',
        snackPosition: SnackPosition.TOP, // 显示在顶部
      ); // 显示错误提示
    }
    for (var friend in friends) {
      if(GlobalData.friendsOnline[friend['accountId']] ?? false){
        friend['online']= true.obs; // 获取好友在线状态
      }else{
        friend['online']= false.obs; // 获取好友在线状态
      }
    }
  }

  void getNotAddedFriends() async {
    print('friends,${friends.map((e) => e['accountId'])}');
    var dio = Dio();
    var params = {
      'friends': [...friends, ...notAddFriends].map((friend) {
        // 创建一个不包含RxBool对象的新Map
        return {'accountId': friend['accountId']};
      }).toList(), // 好友列表
    };
    try {
      final res = await dio.post(
        '${GlobalData.url}/GetNotAddFriends',
        data: params, // 发送请求参数
      );
      if (res.data['code'] == 0) {
        // print('stranger: ${res.data['data']}');
        for (var friend in res.data['data']) {
          if (friend['accountId'] == GlobalData.userInfo['accountId']) {
            continue; // 如果是自己，则跳过
          }
          var inFriends = false;
          friends.any((f) {
            if (f['accountId'] == friend['accountId']) {
              inFriends = true; // 如果已存在，则跳过
              return true; // 终止循环
            }
            return false;
          });
          if (inFriends) {
            continue; // 如果已存在，则跳过
          }
          notAddFriends.add(friend); // 添加好友到列表中
        }
        displayList.assignAll(notAddFriends);
        print(
          'stranger,${notAddFriends.map((f) => f['accountId'])}',
        ); // 打印未添加的好友列表
      } else {
        print(res.data); // 打印错误信息
      }
    } catch (e) {
      print(e); // 打印错误信息
    }
  }

  void invite({required String accountId}) {
    String type;
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
                type = 'ChineseChessWithFriends';
                Get.dialog(
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildSelectButton(
                          " 5 分钟场",
                          5,
                          onTap: () async {
                            Dio dio = Dio();
                            try {
                              final res = await dio.post(
                                '${GlobalData.url}/SendInvitation',
                                data: {
                                  'accountId': accountId,
                                  'invitation': {
                                    'accountId':
                                        GlobalData.userInfo['accountId'],
                                    'type': type,
                                    'gameTime': 5 * 60,
                                    'stepTime': 15,
                                  },
                                },
                              );
                              if (res.data['code'] == 0) {
                                print('发送邀请成功');
                                Get.dialog(
                                  ShowMessageDialog(content: '发送邀请成功'),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(Duration(seconds: 5), () {
                                  socketService.sendInvitation({
                                    'inviterAccountId':
                                        GlobalData.userInfo['accountId'],
                                    'inviteeAccountId': accountId,
                                    'type': type,
                                    'gameTime': 5 * 60,
                                    'stepTime': 15,
                                    'socketRoomId':
                                        GlobalData.userInfo['accountId'] +
                                        '-' +
                                        accountId +
                                        '-' +
                                        DateTime.now().millisecondsSinceEpoch
                                            .toString(),
                                  });
                                  Get.back();
                                  Get.toNamed(
                                    '/ChineseChessBoard',
                                    parameters: {
                                      'type': type,
                                      'accountId': accountId,
                                      'gameTime': (5 * 60).toString(),
                                      "stepTime": 15.toString(),
                                    },
                                  );
                                });
                              } else {
                                print('发送邀请失败,${res.data['msg']}');
                                Get.dialog(
                                  ShowMessageDialog(content: res.data['msg']),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(
                                  Duration(milliseconds: 1500),
                                  () {
                                    Get.back();
                                  },
                                );
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                        buildSelectButton(
                          "10 分钟场",
                          10,
                          onTap: () async {
                            Dio dio = Dio();
                            try {
                              final res = await dio.post(
                                '${GlobalData.url}/SendInvitation',
                                data: {
                                  'accountId': accountId,
                                  'invitation': {
                                    'accountId':
                                        GlobalData.userInfo['accountId'],
                                    'type': type,
                                    'gameTime': 10 * 60,
                                    'stepTime': 30,
                                  },
                                },
                              );
                              if (res.data['code'] == 0) {
                                print('发送邀请成功');
                                Get.dialog(
                                  ShowMessageDialog(content: '发送邀请成功'),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(Duration(seconds: 2), () {
                                  socketService.sendInvitation({
                                    'inviterAccountId':
                                        GlobalData.userInfo['accountId'],
                                    'inviteeAccountId': accountId,
                                    'type': type,
                                    'gameTime': 10 * 60,
                                    'stepTime': 30,
                                    'socketRoomId':
                                        GlobalData.userInfo['accountId'] +
                                        '-' +
                                        accountId +
                                        '-' +
                                        DateTime.now().millisecondsSinceEpoch
                                            .toString(),
                                  });

                                  Get.back();
                                  Get.toNamed(
                                    '/ChineseChessBoard',
                                    parameters: {
                                      'type': "ChineseChessWithFriends",
                                      'accountId': accountId,
                                      'gameTime': (10 * 60).toString(),
                                      "stepTime": 30.toString(),
                                    },
                                  );
                                });
                              } else {
                                print('发送邀请失败,${res.data['msg']}');
                                Get.dialog(
                                  ShowMessageDialog(content: res.data['msg']),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(
                                  Duration(milliseconds: 1500),
                                  () {
                                    Get.back();
                                  },
                                );
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                        buildSelectButton(
                          "15 分钟场",
                          15,
                          onTap: () async {
                            Dio dio = Dio();
                            try {
                              final res = await dio.post(
                                '${GlobalData.url}/SendInvitation',
                                data: {
                                  'accountId': accountId,
                                  'invitation': {
                                    'accountId':
                                        GlobalData.userInfo['accountId'],
                                    'type': type,
                                    'gameTime': 15 * 60,
                                    'stepTime': 60,
                                  },
                                },
                              );
                              if (res.data['code'] == 0) {
                                print('发送邀请成功');
                                Get.dialog(
                                  ShowMessageDialog(content: '发送邀请成功'),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(Duration(seconds: 1), () {
                                  socketService.sendInvitation({
                                    'inviterAccountId':
                                        GlobalData.userInfo['accountId'],
                                    'inviteeAccountId': accountId,
                                    'type': type,
                                    'gameTime': 15 * 60,
                                    'stepTime': 60,
                                    'socketRoomId':
                                        GlobalData.userInfo['accountId'] +
                                        '-' +
                                        accountId +
                                        '-' +
                                        DateTime.now().millisecondsSinceEpoch
                                            .toString(),
                                  });

                                  Get.back();
                                  Get.toNamed(
                                    '/ChineseChessBoard',
                                    parameters: {
                                      'type': "ChineseChessWithFriends",
                                      'accountId': accountId,
                                      'gameTime': (15 * 60).toString(),
                                      "stepTime": 60.toString(),
                                    },
                                  );
                                });
                              } else {
                                print('发送邀请失败,${res.data['msg']}');
                                Get.dialog(
                                  ShowMessageDialog(content: res.data['msg']),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(
                                  Duration(milliseconds: 1500),
                                  () {
                                    Get.back();
                                  },
                                );
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                        buildSelectButton(
                          "20 分钟场",
                          20,
                          onTap: () async {
                            Dio dio = Dio();
                            try {
                              final res = await dio.post(
                                '${GlobalData.url}/SendInvitation',
                                data: {
                                  'accountId': accountId,
                                  'invitation': {
                                    'accountId':
                                        GlobalData.userInfo['accountId'],
                                    'type': type,
                                    'gameTime': 20 * 60,
                                    'stepTime': 60,
                                  },
                                },
                              );
                              if (res.data['code'] == 0) {
                                print('发送邀请成功');
                                Get.dialog(
                                  ShowMessageDialog(content: '发送邀请成功'),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(Duration(milliseconds: 500), () {
                                  socketService.sendInvitation({
                                    'inviterAccountId':
                                        GlobalData.userInfo['accountId'],
                                    'inviteeAccountId': accountId,
                                    'type': type,
                                    'gameTime': 20 * 60,
                                    'stepTime': 60,
                                    'socketRoomId':
                                        GlobalData.userInfo['accountId'] +
                                        '-' +
                                        accountId +
                                        '-' +
                                        DateTime.now().millisecondsSinceEpoch
                                            .toString(),
                                  });
                                  Get.back();
                                  Get.toNamed(
                                    '/ChineseChessBoard',
                                    parameters: {
                                      'type': "ChineseChessWithFriends",
                                      'accountId': accountId,
                                      'gameTime': (20 * 60).toString(),
                                      "stepTime": 60.toString(),
                                    },
                                  );
                                });
                              } else {
                                print('发送邀请失败,${res.data['msg']}');
                                Get.dialog(
                                  ShowMessageDialog(content: res.data['msg']),
                                  barrierDismissible: true,
                                  barrierColor: Colors.transparent,
                                );
                                Future.delayed(
                                  Duration(milliseconds: 1500),
                                  () {
                                    Get.back();
                                  },
                                );
                              }
                            } catch (e) {
                              print(e);
                            }
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
                type = "GoWithFriends";

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
                type = "MilitaryWithFriends";
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
                type = "FirWithFriends";
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
        Map<String, dynamic> delFriend = friends.firstWhere(
          (element) => element['accountId'] == accountId,
        ); // 查找要删除的好友
        notAddFriends.add(delFriend); // 将好友添加到未添加的好友列表中
        friends.removeWhere(
          (friend) => friend['accountId'] == accountId,
        ); // 从列表中删除好友
        GlobalData.userInfo['friends'].removeWhere(
          (friend) => friend == accountId,
        ); // 从全局数据中删除好友
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
    notAddFriends.removeWhere(
      (stranger) =>
          friends.any((friend) => friend['accountId'] == stranger['accountId']),
    );
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
        );
        requestFriends.removeWhere(
          (friend) => friend['accountId'] == accountId,
        ); // 从列表中删除好友
      } else {
        // 显示错误提示
        Get.dialog(
          ShowMessageDialog(content: response.data['msg']), // 显示消息对话框
        );
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
      displayList.clear(); // 如果关键字为空，清空搜索结果列表
      notAddFriends.removeWhere(
        (stranger) => friends.any(
          (friend) => friend['accountId'] == stranger['accountId'],
        ),
      );
      displayList.addAll(notAddFriends); // 显示未添加的好友列表
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
        displayList.clear(); // 清空搜索结果列表
        for (var friend in response.data['data']) {
          print(friend);
          if (friend['accountId'] != GlobalData.userInfo['accountId']) {
            displayList.add(friend); // 添加搜索结果到列表中
          }
        }
      }
    } catch (e) {
      print('e:$e');
    }
  }

  Future<void> refreshFriends() async {
    getFriends();
  }

  // 展示个人信息
  void showPersonalInfo(String accountId) async {
    String avatar =
        'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/xiaobinggan.jpg';
    String username = '';
    String description = '';
    int activity = 0;
    int gold = 0;
    int coupon = 0;
    Dio dio = Dio();
    Map<String, dynamic> params = {'accountId': accountId};
    try {
      final res = await dio.post("${GlobalData.url}/GetUserInfo", data: params);
      if (res.data['code'] == 0) {
        print(res.data);
        avatar = res.data['avatar'];
        username = res.data['username'];
        description = res.data['description'];
        activity = res.data['activity'].toInt();
        gold = res.data['gold'].toInt();
        coupon = res.data['coupon'].toInt();
      } else {
        print(res.data['msg']);
      }
    } catch (e) {
      print(e);
      print('获取用户信息失败');
    }
    ;

    Get.dialog(
      BuildPersonalInfoCard(
        avatar: avatar,
        username: username,
        accountId: accountId,
        description: description,
        activity: activity,
        gold: gold,
        coupon: coupon,
        isFriend: friends.any((friend) => friend['accountId'] == accountId),
        onLevelTap: () => onLevelTap(accountId),
        onFriendTap: () => onFriendTap(accountId),
        onSendConversationMessage: () => onSendConversationMessage(accountId),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.001),
    );
  }

  // 点击等级信息
  void onLevelTap(String accountId) {
    Get.toNamed('/Level', parameters: {'accountId': accountId});
  }

  // 点击添加好友
  void onFriendTap(String accountId) {
    if (GlobalData.userInfo['friends'].contains(accountId)) {
      Get.dialog(
        ShowMessageDialog(content: '你们已经是好友了'),
        barrierDismissible: true,
        barrierColor: Colors.transparent,
      );
      Future.delayed(Duration(seconds: 1), () {
        Get.back();
      });
    } else {
      final MyFriendsController myFriendsController = Get.find();
      myFriendsController.request(accountId: accountId);
    }
  }

  // 发送消息
  void onSendConversationMessage(String accountId) {
    Get.toNamed('/ChatWindow', parameters: {'accountId': accountId});
  }
}
