import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'conversation_controller.dart';

class Conversations extends StatelessWidget {
  Conversations({super.key});
  final ConversationsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/MyInfo/BackGround.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            AppBar(
              title: Text(
                '会话列表',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          /// 背景木板
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 消息列表
          Obx(
            () => ListView.builder(
              itemCount: controller.conversationsList.length,
              itemBuilder: (context, index) {
                final conv = controller.conversationsList[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(
                    () => ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              conv.opponent['avatar'],
                            ),
                            radius: 25,
                          ),
                          if (conv.unreadCnt.value > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Obx(
                                  () => Text(
                                    conv.unreadCnt.value > 99
                                        ? "99+"
                                        : "${conv.unreadCnt.value}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(conv.opponent['username']),
                      subtitle: Text(
                        conv.lastMessage.value.length > 20
                            ? conv.lastMessage.value.substring(0, 20) + '...'
                            : conv.lastMessage.value,
                      ),
                      trailing: Text(
                        "${conv.lastTime.value.hour}:${conv.lastTime.value.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () async {
                        await controller.markAsRead(conv.conversationId);
                        Get.toNamed(
                          '/ChatWindow',
                          parameters: {
                            'accountId': conv.opponent['accountId'], // 传递接收者ID
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
