import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../global/global_data.dart'; // 存储全局数据
import '../widgets/invite_dialog.dart'; // 显示邀请弹窗
import 'package:get/get.dart';
import '../widgets/show_message_dialog.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  String? _roomId = '';

  // ---- 事件流 ----
  StreamController<Map<String, dynamic>>? _moveController;
  Stream<Map<String, dynamic>> get onMove =>
      _moveController?.stream ?? const Stream.empty();

  StreamController<Map<String, dynamic>>? _matchSuccessController;
  Stream<Map<String, dynamic>> get onMatchSuccess =>
      _matchSuccessController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _waitingController;
  Stream<dynamic> get onWaiting =>
      _waitingController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _disconnectController;
  Stream<dynamic> get onDisconnect =>
      _disconnectController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _opponentDisconnectController;
  Stream<dynamic> get onOpponentDisconnect =>
      _opponentDisconnectController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _reconnectController;
  Stream<dynamic> get onReconnect =>
      _reconnectController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _opponentReconnectController;
  Stream<dynamic> get onOpponentReconnect =>
      _opponentReconnectController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _opponentReadyController;
  Stream<dynamic> get onOpponentReady =>
      _opponentReadyController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _opponentDealInvitationController;
  Stream<dynamic> get onOpponentDealInvitation =>
      _opponentDealInvitationController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _roomJoinedController;
  Stream<dynamic> get onRoomJoined =>
      _roomJoinedController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _receiveMessagesController;
  Stream<dynamic> get onReceiveMessages =>
      _receiveMessagesController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _receiveActionsController;
  Stream<dynamic> get onReceiveActions =>
      _receiveActionsController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _opponentLeaveController;
  Stream<dynamic> get onOpponentLeave =>
      _opponentLeaveController?.stream ?? const Stream.empty();

  // ---- 初始化连接 ----
  void initSocket() {
    if (_socket != null && _socket!.connected) {
      print("⚠️ Socket 已连接，无需重新初始化");
      return;
    }

    // 创建 StreamController 实例
    _moveController?.close();
    _moveController = StreamController<Map<String, dynamic>>.broadcast();

    _matchSuccessController?.close();
    _matchSuccessController =
        StreamController<Map<String, dynamic>>.broadcast();

    _waitingController?.close();
    _waitingController = StreamController<dynamic>.broadcast();

    _disconnectController?.close();
    _disconnectController = StreamController<dynamic>.broadcast();

    _reconnectController?.close();
    _reconnectController = StreamController<dynamic>.broadcast();

    _opponentDisconnectController?.close();
    _opponentDisconnectController = StreamController<dynamic>.broadcast();

    _opponentReconnectController?.close();
    _opponentReconnectController = StreamController<dynamic>.broadcast();

    _opponentDealInvitationController?.close();
    _opponentDealInvitationController = StreamController<dynamic>.broadcast();

    _opponentReadyController?.close();
    _opponentReadyController = StreamController<dynamic>.broadcast();

    _roomJoinedController?.close();
    _roomJoinedController = StreamController<dynamic>.broadcast();

    _receiveMessagesController?.close();
    _receiveMessagesController = StreamController<dynamic>.broadcast();

    _receiveActionsController?.close();
    _receiveActionsController = StreamController<dynamic>.broadcast();

    _opponentLeaveController?.close();
    _opponentLeaveController = StreamController<dynamic>.broadcast();

    _socket = IO.io(
      'http://120.48.156.237:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .setAuth({'accountId': GlobalData.userInfo['accountId']})
          .setReconnectionAttempts(20)
          .setReconnectionDelay(2000)
          .build(),
    );

    // --- 基础事件 ---
    _socket?.onConnect((_) {
      print("✅ Socket 已连接: ${_socket?.id}");

      if (_roomId != '') {
        reconnectRoom();
      }
    });

    _socket?.onDisconnect((_) {
      print("❌ Socket 已断开");
      if (_disconnectController?.isClosed == false) {
        _disconnectController?.add(true);
      }
    });

    _socket?.onReconnect((attempt) {
      print("🔄 正在重连... 第 $attempt 次");
    });

    _socket?.onReconnectError((err) {
      print("⚠️ 重连错误: $err");
    });

    _socket?.onReconnectFailed((_) {
      print("❌ 重连失败，放弃尝试");
    });

    _socket?.onConnectError((err) {
      print("⚠️ 连接错误: $err");
    });

    _socket?.onError((err) {
      print("⚠️ Socket 错误: $err");
    });

    // --- 业务事件 ---
    _socket?.on('reconnect_success', (data) {
      print("🔄 重新连接房间成功: $data");
      if (_reconnectController?.isClosed == false) {
        _reconnectController?.add(data);
      }
    });

    // 匹配成功
    _socket?.on('match_success', (data) {
      print("🎯 匹配成功: $data");
      if (_matchSuccessController?.isClosed == false) {
        _matchSuccessController?.add(Map<String, dynamic>.from(data));
        _roomId = data['roomId']; // 更新房间 ID
        print('roomId,$_roomId');
      }
    });

    // 对方准备
    _socket?.on('opponentReady', (accountId) {
      print('对方已准备');
      if (_opponentReadyController?.isClosed == false) {
        _opponentReadyController?.add(accountId); // 发送空数据
      }
    });

    // 对方离开
    _socket?.on('opponentLeave', (_) {
      print('对方已离开');
      if (_opponentLeaveController?.isClosed == false) {
        _opponentLeaveController?.add(true); // 发送空数据
      }
    });

    // 匹配失败
    _socket?.on('match_error', (data) {
      print("❌ 匹配失败: $data");
    });

    // 等待中
    _socket?.on('waiting', (data) {
      print("⌛ 等待中: $data");
      if (_waitingController?.isClosed == false) {
        _waitingController?.add(data);
      }
    });

    // 接收落子
    _socket?.on('move', (data) {
      print("♟ 对手落子: $data");
      if (data is Map && _moveController?.isClosed == false) {
        _moveController?.add(Map<String, dynamic>.from(data));
      }
    });

    // 接收消息
    _socket?.on('receiveMessages', (data) {
      print("📩 收到消息: $data");
      if (_receiveMessagesController?.isClosed == false) {
        _receiveMessagesController?.add(data);
      }
    });

    // 接收动作
    _socket?.on('receiveActions', (data) {
      print("🕹 对手请求: $data");
      if (_receiveActionsController?.isClosed == false) {
        _receiveActionsController?.add(data);
      }
    });

    // 对手断线
    _socket?.on('opponentDisconnect', (_) {
      print("❤️ 对手断线");
      if (_opponentDisconnectController?.isClosed == false) {
        print('通知前端对手断线');
        _opponentDisconnectController?.add(true); // 发送空数据
      }
    });

    // 对方重新连接
    _socket?.on('opponentReconnect', (_) {
      print('❤️ 对方重新连接');
      if (_opponentReconnectController?.isClosed == false) {
        _opponentReconnectController?.add(true); // 发送空数据
      }
    });

    // 接收邀请
    _socket?.on('receiveInvitation', (data) {
      print('receiveInvitation,$data');
      print(
        '${data['gameTime'].runtimeType},${data['stepTime'].runtimeType},${data['type'].runtimeType}',
      );
      if (GlobalData.isPlaying == true) {
        data['deal'] = 'playing';
        dealInvitation(data);
      } else {
        Get.dialog(
          InviteDialog(
            avatar: data['avatar'],
            accountId: data['inviterAccountId'],
            username: data['username'],
            type: transform(data['type']),
            gameTime: ((data['gameTime'] / 60).toInt() ?? 0).toString() + '分',
            stepTime: (data['stepTime'] ?? 0).toString() + '秒',
            onAccept: () {
              data['deal'] = 'accept';
              dealInvitation(data);
              Get.back();
            },
            onReject: () {
              data['deal'] = 'reject';
              dealInvitation(data);
              Get.back();
            },
          ),
          barrierDismissible: true,
          barrierColor: Colors.transparent,
        );
      }
    });

    // 对方处理邀请
    _socket?.on('opponentDealInvitation', (data) {
      print('opponentDealInvitation,$data');
      if (_opponentDealInvitationController?.isClosed == false) {
        _opponentDealInvitationController?.add(data);
      }
    });

    // 房间已加入
    _socket?.on('room_joined', (data) {
      print('room_joined,房间建立');
      _roomId = data['roomId'];
      Get.toNamed(
        '/ChineseChessBoard',
        parameters: {
          'type': 'ChineseChessWithFriends',
          'accountId': data['inviter']['accountId'],
          'gameTime': data['gameTime'].toString(),
          'stepTime':
              (data['gameTime'] == 1200 || data['gameTime'] == 900
                      ? 60
                      : data['gameTime'] == 600
                      ? 30
                      : 15)
                  .toString(),
        },
      );
      if (_roomJoinedController?.isClosed == false) {
        Future.delayed((const Duration(milliseconds: 50)), () {
          _roomJoinedController?.add(data);
        });
      }
    });

    // 房间不存在
    _socket?.on('roomNotExist', (_) {
      print('房间不存在');
      Get.dialog(
        ShowMessageDialog(content: '房间不存在'),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    });

    // 开始连接
    _socket!.connect();
  }

  // ---- 发送匹配请求 ----
  void sendMatchRequest(String type, Map<String, dynamic> params) {
    if (_socket == null || !_socket!.connected) {
      print("⚠️ Socket 未连接，重新初始化...");
      initSocket();
    }
    print("📤 发送匹配请求: $type => $params");
    _socket?.emit(type, params);
  }

  // ---- 通知对方我方已准备 ----
  void sendReady(String opponentAccountId) {
    if (_socket?.connected == true) {
      print("📤 通知对方我方已准备");
      _socket?.emit('ready', opponentAccountId);
    } else {
      print("⚠️ 未连接，无法发送准备消息");
    }
  }

  // ---- 发送落子 ----
  void sendMove(Map<String, dynamic> move) {
    if (_socket?.connected == true) {
      print("📤 发送落子: $move");
      _socket?.emit('move', move);
    } else {
      print("⚠️ 未连接，无法发送落子");
    }
  }

  // --- 发送actions ---
  void sendActions(Map<String, dynamic> actions) {
    if (_socket?.connected == true) {
      print("📤 发送请求: $actions");
      _socket?.emit('sendActions', actions);
    }
  }

  // ---- 发送消息 ----
  void sendMessages(Map<String, dynamic> messages) {
    if (_socket?.connected == true) {
      print("📤 发送消息: $messages");
      _socket?.emit('sendMessages', messages);
    }
  }

  // ---- 发送取消匹配 ----
  void cancelMatch() {
    if (_socket?.connected == true) {
      print("📤 发送取消匹配");
      _socket?.emit('cancelMatch');
    } else {
      print("⚠️ 未连接，无法发送取消匹配");
    }
  }

  // ---- 发送邀请 ----
  void sendInvitation(Map<String, dynamic> params) {
    if (_socket?.connected == true) {
      print("📤 发送邀请: $params");
      _socket?.emit('sendInvitation', params);
    } else {
      print("⚠️ 未连接，无法发送邀请");
    }
  }

  // ---- 处理邀请 ----
  void dealInvitation(Map<String, dynamic> params) {
    if (_socket?.connected == true) {
      print("📤 发送接受邀请: $params");
      _socket?.emit('dealInvitation', params);
    } else {
      print("⚠️ 未连接，无法发送接受邀请");
    }
  }

  // ---- 发送我方信息 ----
  void sendOpponentInformation(data) {
    if (_socket?.connected == true) {
      print('sendOpponentInformation,$data');
      _socket?.emit('sendOpponentInformation', data);
    } else {
      print("⚠️ 未连接，无法响应");
    }
  }

  // ---- 重新连接房间 ----
  void reconnectRoom() {
    print("🔄 reconnectRoom重新连接房间,${_roomId}");
    print('roomId,$_roomId');
    _socket?.emit('reconnectRoom', {
      'roomId': _roomId,
      'accountId': GlobalData.userInfo['accountId'],
    });
  }

  // ---- 游戏结束 ----
  void overGame() {
    _roomId = '';
    GlobalData.isPlaying = false;
  }

  // ---- 销毁 ----
  void dispose() {
    print("🧹 销毁 SocketService");

    // 取消所有事件监听
    _socket?.off('waiting');
    _socket?.off('move');
    _socket?.off('match_success');
    _socket?.off('match_error');
    _socket?.off('pong');
    _socket?.offAny();

    _moveController?.close();
    _moveController = null;

    _matchSuccessController?.close();
    _matchSuccessController = null;

    _waitingController?.close();
    _waitingController = null;

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _roomId = '';
  }
}

String transform(String? type) {
  if (type == null) {
    return '';
  }
  if (type.contains('ChineseChess')) {
    return '中国象棋';
  } else if (type.contains('Go')) {
    return '围棋';
  } else if (type.contains('military')) {
    return '军棋';
  } else {
    return '五子棋';
  }
}
