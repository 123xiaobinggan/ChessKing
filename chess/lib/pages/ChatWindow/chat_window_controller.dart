import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../global/global_data.dart';
import 'package:dio/dio.dart';
import '../../widgets/build_personal_info_card.dart';
import '../../widgets/show_message_dialog.dart';
import '../MyFriends/my_friends_controller.dart';

class ChatWindowController extends GetxController {
  RxMap<String, dynamic> opponentInfo = <String, dynamic>{
    "accountId": "123456",
    "username": "".obs,
    "avatar":
        "https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png"
            .obs,
  }.obs; // 用户信息，包括用户名和头像
  final displayItems = [].obs;
  final textEditingController = TextEditingController(); // 输入框控制器
  final socketServeice = GlobalData.socketService;
  String conversationId = '';

  StreamSubscription<dynamic>? _ReceiveConversationMessageSubscription;

  @override
  void onInit() async {
    opponentInfo['accountId'] = Get.parameters['accountId']; // 从路由参数中获取用户信息
    await getOpponentInfo(); // 获取用户信息
    print('opponentInfo: $opponentInfo');
    await getConversationId();
    print('conversationId: $conversationId');
    if (conversationId != '') {
      await getMessages();
    }
    _ReceiveConversationMessageSubscription = socketServeice
        .onReceiveConversationMessage
        .listen((message) {
          // 监听接收消息事件
          print('message: $message'); // 打印接收到的消息
          receiveConversationMessage(message);
        });
    super.onInit();
  }

  // 获取好友信息
  Future<void> getOpponentInfo() async {
    if (Get.parameters['username'] != null && Get.parameters['avatar'] != '') {
      opponentInfo['username'].value = Get.parameters['username']; // 获取用户信息
      opponentInfo['avatar'].value = Get.parameters['avatar']; // 获取用户信息
      return;
    }
    Dio dio = Dio();
    Map<String, dynamic> data = {
      "accountId": opponentInfo['accountId'], // 要查询的用户ID
    };
    try {
      final res = await dio.post(GlobalData.url + '/GetUserInfo', data: data);
      if (res.data['code'] == 0) {
        opponentInfo['username'].value = res.data['username']; // 获取用户信息
        opponentInfo['avatar'].value = res.data['avatar']; // 获取用户信息
      } else {
        print('获取用户信息失败: ${res.data['message']}');
        Get.dialog(
          ShowMessageDialog(content: '获取信息失败'),
          barrierDismissible: false,
          barrierColor: Colors.transparent,
        );
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      print('e,$e');
      Get.dialog(
        ShowMessageDialog(content: '获取信息失败'),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
      );
      Future.delayed(Duration(milliseconds: 1500), () {
        Get.back();
      });
    }
  }

  // 获取会话ID
  Future<void> getConversationId() async {
    Dio dio = Dio();
    Map<String, dynamic> data = {
      "accountId1": GlobalData.userInfo['accountId'], // 用户ID
      "accountId2": opponentInfo['accountId'], // 好友ID
    };
    try {
      final res = await dio.post(
        GlobalData.url + '/GetConversationId',
        data: data,
      );
      if (res.data['code'] == 0) {
        conversationId = res.data['conversationId'];
      } else {
        print('获取会话ID失败: ${res.data['msg']}');
        Get.dialog(
          ShowMessageDialog(content: '获取会话ID失败'),
          barrierDismissible: false,
          barrierColor: Colors.transparent,
        );
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      print('e,$e');
    }
  }

  // 获取历史对话消息
  Future<void> getMessages() async {
    DateTime createdAt = DateTime.now();
    for (var item in displayItems) {
      if (item['type'] == 'message') {
        createdAt = item['message'].createdAt;
        break;
      }
    }
    Dio dio = Dio();
    Map<String, dynamic> data = {
      "conversationId": conversationId, // 会话ID"
      "createdAt": createdAt.toIso8601String(),
    };
    print('获取消息列表: $data');
    try {
      final res = await dio.post(GlobalData.url + '/GetMessages', data: data);
      if (res.data['code'] == 0) {
        print('获取消息列表成功: ${res.data['messages']}');
        final List<Message> newMessages = (res.data['messages'] as List)
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
        newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        buildMessageWithTimeDivider(newMessages);
      } else {
        print('获取消息列表失败: ${res.data['message']}');
        Get.dialog(
          ShowMessageDialog(content: '获取消息列表失败'),
          barrierDismissible: false,
          barrierColor: Colors.transparent,
        );
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      print('e,$e');
    }
  }

  // 发送消息
  Future<void> sendMessage() async {
    if (conversationId == '') {
      Get.dialog(
        ShowMessageDialog(content: '发送错误'),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
      );
      Future.delayed(Duration(milliseconds: 1500), () {
        Get.back();
      });
      return;
    }
    Message message = Message(
      conversationId: conversationId,
      senderAccountId: GlobalData.userInfo['accountId'], // 发送者ID
      receiverAccountId: opponentInfo['accountId'], // 接收者ID
      content: textEditingController.text, // 消息内容
      createdAt: DateTime.now(),
    );
    print("发送消息: $message");
    textEditingController.clear(); // 清空输入框
    socketServeice.sendConversationMessage(message.toJson());
  }

  //收到消息
  void receiveConversationMessage(Map<String, dynamic> message) {
    final Message m = Message.fromJson(message);
    if (displayItems.isEmpty) {
      displayItems.add({"type": "time", "time": m.createdAt});
    } else {
      final diff = m.createdAt
          .difference(
            displayItems[displayItems.length - 1]['message'].createdAt,
          )
          .inMinutes;
      if (diff > 5) {
        displayItems.add({"type": "time", "time": m.createdAt});
      }
    }
    displayItems.add({"type": "message", "message": m});
    if (m.receiverAccountId == GlobalData.userInfo['accountId']) {
      markAsRead(); // 标记已读
    }
  }

  // 标记已读
  void markAsRead() async {
    Dio dio = Dio();
    Map<String, dynamic> data = {
      "accountId": GlobalData.userInfo['accountId'], // 用户ID
      "conversationId": conversationId, // 会话ID
    };
    try {
      final res = await dio.post(GlobalData.url + '/MarkAsRead', data: data);
      if (res.data['code'] == 0) {
        print('标记已读成功');
      }
    } catch (e) {
      print('e,$e');
    }
  }

  // 构建消息
  void buildMessageWithTimeDivider(List<Message> messages) {
    print('buildMessageWithTimeDivider');
    final tempDisplayItems = [];
    for (int i = 0; i < messages.length; i++) {
      final current = messages[i];

      // 如果是第一条消息，先加一个时间分割点
      if (i == 0) {
        tempDisplayItems.add({"type": "time", "time": current.createdAt});
      } else {
        final prev = messages[i - 1];
        final diff = current.createdAt.difference(prev.createdAt).inMinutes;

        if (diff > 5) {
          // 超过5分钟，加一个时间分割点
          tempDisplayItems.add({"type": "time", "time": current.createdAt});
        }
      }

      // 再加消息本身
      tempDisplayItems.add({"type": "message", "message": current});
    }
    displayItems.insertAll(0, tempDisplayItems);
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
        isFriend: true,
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

  // 点击对方头像并点击发送消息
  void onSendConversationMessage(String accountId) {
    String currentRoute = Get.routing.current;
    print('currentRoute: $currentRoute');
    if (currentRoute.contains('/ChatWindow')) {
      Get.back();
    } else {
      Get.toNamed('/ChatWindow', parameters: {'accountId': accountId});
    }
  }

  @override
  void onClose() {
    super.onClose();
    dispose();
    _ReceiveConversationMessageSubscription?.cancel();
    _ReceiveConversationMessageSubscription = null;
  }
}

class Message {
  final String conversationId;
  final String senderAccountId; // 发送者
  final String receiverAccountId; // 接收者
  final String content; // 消息内容
  final DateTime createdAt;

  Message({
    required this.conversationId,
    required this.senderAccountId,
    required this.receiverAccountId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'senderAccountId': senderAccountId,
      'receiverAccountId': receiverAccountId,
      'content': content,
      'createdAt': createdAt.toIso8601String(), // 转换为ISO 8601格式的字符串
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      conversationId: json['conversationId'],
      senderAccountId: json['senderAccountId'],
      receiverAccountId: json['receiverAccountId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }
}
