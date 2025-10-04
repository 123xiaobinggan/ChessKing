import 'dart:async';
import 'package:get/get.dart';
import '../../global/global_data.dart';
import 'package:dio/dio.dart';

class ConversationsController extends GetxController {
  final count = 0.obs;
  final accountId = ''.obs;
  final conversationsList = <Conversation>[].obs;
  final socketServeice = GlobalData.socketService;
  StreamSubscription<dynamic>? _receiveConversationMessagesubscription;

  @override
  void onInit() async {
    super.onInit();
    await getConversations();
    _receiveConversationMessagesubscription = socketServeice
        .onReceiveConversationMessage
        .listen((message) {
          print('onReceiveConversationMessage: $message');
          for (var conv in conversationsList) {
            if (conv.conversationId == message['conversationId']) {
              conv.lastMessage.value = message['content']; // 更新最后一条消息
              conv.lastTime.value = DateTime.parse(
                message['createdAt'],
              ).toLocal(); // 更新最后一条消息的时间
              if (message['receiverAccountId'] ==
                  GlobalData.userInfo['accountId']) {
                conv.unreadCnt.value++; // 未读消息数量加1
              }
              print('unreadCnt:${conv.unreadCnt.value}');
              print('conv: ${conv.toJson()}');
              break;
            }
          }
        });
  }

  // 获取会话列表
  Future<void> getConversations() async {
    Dio dio = Dio();
    Map<String, dynamic> data = {
      "accountId": GlobalData.userInfo['accountId'], // 用户ID
    };
    try {
      final res = await dio.post(
        GlobalData.url + '/GetConversations',
        data: data,
      );
      if (res.data['code'] == 0) {
        final List<dynamic> conversations = res.data['conversations']; // 获取会话列表
        print('conversations: $conversations');
        conversationsList.assignAll(
          conversations
              .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        print('conversationsList: ${conversationsList.map((e) => e.toJson())}');
      } else {
        print('获取会话列表失败: ${res.data['message']}');
      }
    } catch (e) {
      print('e,$e');
    }
  }

  // 进入聊天页面时，清空未读
  Future<void> markAsRead(String conversationId) async {
    for (var conv in conversationsList) {
      if (conv.conversationId == conversationId) {
        conv.unreadCnt.value = 0; // 未读消息数量清零
        break;
      }
    }
    Dio dio = Dio();
    Map<String, dynamic> data = {
      "accountId": GlobalData.userInfo['accountId'], // 用户ID
      "conversationId": conversationId, // 会话ID
    };
    try {
      final res = await dio.post(GlobalData.url + '/MarkAsRead', data: data);
      if (res.data['code'] == 0) {
        print('标记已读成功: ${res.data['message']}');
      } else {
        print('标记已读失败: ${res.data['message']}');
      }
    } catch (e) {
      print('e,$e');
    }
  }

  @override
  void onClose() {
    super.onClose();
    _receiveConversationMessagesubscription?.cancel();
    _receiveConversationMessagesubscription = null;
  }
}

class Conversation {
  String conversationId;
  Map<String, dynamic> opponent;
  RxString lastMessage = ''.obs;
  Rx<DateTime> lastTime = DateTime.now().obs;
  RxInt unreadCnt = 0.obs;

  Conversation({
    required this.conversationId,
    required this.opponent,
    String? lastMessage,
    required this.lastTime,
    int? unreadCnt,
  }) {
    this.lastMessage.value = lastMessage ?? '';
    this.unreadCnt.value = unreadCnt ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'opponent': opponent,
      'lastMessage': lastMessage.value,
      'lastTime': lastTime.value.toIso8601String(),
      'unreadCnt': unreadCnt.value,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] ?? '',
      opponent: json['opponent'] ?? {},
      lastTime: DateTime.parse(json['lastTime'] ?? '').toLocal().obs,
      lastMessage: json['lastMessage'] ?? '',
      unreadCnt: json['unreadCnt'] ?? 0,
    );
  }
}
