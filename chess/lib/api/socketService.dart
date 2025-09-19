import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  // ---- 事件流 ----
  StreamController<Map<String, dynamic>>? _moveController;
  Stream<Map<String, dynamic>> get onMove => _moveController?.stream ?? const Stream.empty();

  StreamController<Map<String, dynamic>>? _matchSuccessController;
  Stream<Map<String, dynamic>> get onMatchSuccess => _matchSuccessController?.stream ?? const Stream.empty();

  StreamController<dynamic>? _waitingController;
  Stream<dynamic> get onWaiting => _waitingController?.stream ?? const Stream.empty();

  // ---- 初始化连接 ----
  void initSocket() {
    if (_socket != null && _socket!.connected) {
      print("⚠️ Socket 已连接，无需重新初始化");
      return;
    }

    // 重新创建 StreamController 实例
    _moveController?.close();
    _moveController = StreamController<Map<String, dynamic>>.broadcast();
    
    _matchSuccessController?.close();
    _matchSuccessController = StreamController<Map<String, dynamic>>.broadcast();
    
    _waitingController?.close();
    _waitingController = StreamController<dynamic>.broadcast();

    _socket = IO.io(
      'http://120.48.156.237:3000',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(5)
          .build(),
    );

    // --- 基础事件 ---
    _socket?.onConnect((_) {
      print("✅ Socket 已连接: ${_socket?.id}");
    });

    _socket?.onDisconnect((_) {
      print("❌ Socket 已断开");
    });

    _socket?.onConnectError((err) {
      print("⚠️ 连接错误: $err");
    });

    _socket?.onError((err) {
      print("⚠️ Socket 错误: $err");
    });

    // --- 业务事件 ---
    _socket?.on('match_success', (data) {
      print("🎯 匹配成功: $data");
      if (_matchSuccessController?.isClosed == false) {
        _matchSuccessController?.add(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('match_error', (data) {
      print("❌ 匹配失败: $data");
    });

    _socket?.on('waiting', (data) {
      print("⌛ 等待中: $data");
      if (_waitingController?.isClosed == false) {
        _waitingController?.add(data);
      }
    });

    _socket?.on('move', (data) {
      print("♟ 对手落子: $data");
      if (data is Map && _moveController?.isClosed == false) {
        _moveController?.add(Map<String, dynamic>.from(data));
      }
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

  // ---- 发送落子 ----
  void sendMove(Map<String, dynamic> move) {
    if (_socket?.connected == true) {
      print("📤 发送落子: $move");
      _socket?.emit('move', move);
    } else {
      print("⚠️ 未连接，无法发送落子");
    }
  }

  // ---- 发送取消匹配 ----
  void disconnect() {
    if (_socket?.connected == true) {
      print("📤 发送取消匹配");
      _socket?.disconnect();
    } else {
      print("⚠️ 未连接，无法发送取消匹配");
    }
  }

  // ---- 销毁 ----
  void dispose() {
    print("🧹 销毁 SocketService");

    // 取消所有事件监听
    _socket?.off('waiting');
    _socket?.off('move');
    _socket?.off('match_success');
    _socket?.off('match_error');
    _socket?.offAny();

    // 不再关闭 StreamController，而是将它们设为 null
    _moveController?.close();
    _moveController = null;
    
    _matchSuccessController?.close();
    _matchSuccessController = null;
    
    _waitingController?.close();
    _waitingController = null;

    // 断开连接
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}