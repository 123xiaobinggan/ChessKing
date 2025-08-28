import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import '/global/global_data.dart'; // 存储全局数据
import 'package:get/get.dart';

class PushManager {
  static final _jpush = JPush.newJPush();

  /// 初始化
  static Future<void> init() async {
    // JPush SDK 初始化
    _jpush.setup(
      appKey: "74dacc1e2e26774220395b0e",
      channel: "4de60b2fb9fda99e39c12292",
      production: false,
      debug: true,
    );

    // 获取注册 ID（设备唯一推送标识）
    _jpush.getRegistrationID().then((rid) {
      debugPrint("JPush RegistrationID: $rid");
      GlobalData.rid = rid;
    });

    // 监听各种回调
    _jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        debugPrint("收到通知: $message");
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        debugPrint("点击通知: $message");
        GlobalData.pendingNotification = message;
        _handleNotification(message);
      },
      onReceiveMessage: (Map<String, dynamic> message) async {
        debugPrint("收到自定义消息: $message");
      },
    );

    // 冷启动检查（App 被杀死后，点击通知启动）
    _jpush.getLaunchAppNotification().then((Map<dynamic, dynamic>? message) {
      if (message != null) {
        debugPrint("冷启动收到通知: $message");
        GlobalData.pendingNotification = message;
      }
    });
  }

  /// 通知处理方法
  static void _handleNotification(Map<dynamic, dynamic> message) {
    var extras = message['extras'];
    var extraData = extras?['cn.jpush.android.EXTRA'];

    if (extraData is String) {
      extraData = jsonDecode(extraData);
    }

    if (extraData != null && extraData['roomId'] != null) {
      String roomId = extraData['roomId'].toString();
      String accountId = extraData['accountId'].toString();
      String type = extraData['type'].toString();
      int gameTime = int.tryParse(extraData['gameTime'].toString()) ?? 0;
      int stepTime = int.tryParse(extraData['stepTime'].toString()) ?? 0;

      // 如果用户已登录，直接跳转
      if (GlobalData.isLoggedIn) {
        Get.toNamed(
          '/ChineseChessBoard',
          parameters: {
            'roomId': roomId,
            'accountId': accountId,
            'type': type,
            'gameTime': gameTime.toString(),
            'stepTime': stepTime.toString(),
          },
        );
      } else {
        // 没登录，等登录成功再跳
        GlobalData.pendingNotification = message;
      }
    }
  }

  /// 登录成功时调用，执行未处理的通知
  static void handlePendingAfterLogin() {
    if (GlobalData.pendingNotification != null) {
      _handleNotification(GlobalData.pendingNotification!);
      GlobalData.pendingNotification = null;
    }
  }
}
