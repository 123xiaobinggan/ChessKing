import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/pages/ChineseChessBoard/Chinese_chess_board_controller.dart';
import '/widgets/build_player_info_block.dart';
import '/widgets/build_menu_item.dart';
import '/widgets/chat_phrase_chip.dart';
import '/widgets/speech_bubble.dart';
import '/widgets/Chinese_chess_board_piece.dart';
import '/widgets/confirm_dialog.dart';


class ChineseChessBoard extends StatelessWidget {
  ChineseChessBoard({super.key});

  final ChineseChessBoardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.type = Get.parameters['type'] ?? 'ChineseChessMatch';
    controller.opponentAccountId = Get.parameters['accountId'] ?? '空座';
    controller.gameTime.value =
        int.tryParse(Get.parameters['gameTime'] ?? '900') ?? 900;
    controller.stepTime.value =
        int.tryParse(Get.parameters['stepTime'] ?? '60') ?? 60;
    controller.roomId = Get.parameters['roomId'] ?? '';
    print('roomId:${controller.roomId}');
    print('type:${controller.type}');
    print('opponentAccountId:${Get.parameters['accountId']}');
    print('gameTime:${controller.gameTime.value}');
    print('stepTime:${controller.stepTime.value}');
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  '小试牛刀',
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
                    if (controller.stage.value == GameStage.playing) {
                      Get.dialog(
                        ConfirmDialog(
                          content: '是否要离开游戏？',
                          onConfirm: () {
                            Get.back(); // 确认退出
                            Get.back();
                          },
                          onCancel: () {
                            Get.back();
                          },
                        ),
                      );
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 点击空白处收起键盘
            controller.showMenu.value = false; // 收起菜单
            controller.showChat.value = false; // 收起聊天框
          },
          child: Stack(
            children: [
              // 背景图
              Positioned.fill(
                child: Image.asset(
                  'assets/MyInfo/BackGround.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 对方头像（左上角）
              Positioned(
                top: 10,
                left: 16,
                child: Obx(
                  () => buildPlayerInfoBlock(
                    username: controller.playInfo['opponent']['username'].value,
                    accountId:
                        controller.playInfo['opponent']['accountId'].value,
                    level: controller.playInfo['opponent']['level'].value,
                    isMyTurn: controller.playInfo['opponent']['myTurn'],
                    imagePath: controller
                        .playInfo['opponent']['avatar']
                        .value, // 替换为你的头像路径
                    isRed: controller
                        .playInfo['opponent']['isRed'], // 设置为 false 表示不是我方
                    totalTime: controller
                        .playInfo['opponent']['remaining_time']
                        .value, // 总时间
                    stepTime: controller.opponentStepTime.value, // 步长时间
                  ),
                ),
              ),

              // 我的头像（左下角）
              Positioned(
                bottom: 16,
                right: 16,
                child: Obx(
                  () => buildPlayerInfoBlock(
                    username: controller.playInfo['me']['username'] ?? '',
                    accountId: controller.playInfo['me']['accountId'] ?? '',
                    level: controller.playInfo['me']['level'] ?? '',
                    isMyTurn: controller.playInfo['me']['myTurn'],
                    imagePath: controller.playInfo['me']['avatar'], // 替换为你的头像路径
                    isRed:
                        controller.playInfo['me']['isRed'], // 设置为 false 表示不是我方
                    totalTime: controller
                        .playInfo['me']['remaining_time']
                        .value, // 总时间
                    stepTime: controller.myStepTime.value, // 步长时间
                  ),
                ),
              ),

              // 菜单
              Positioned(
                bottom: 80, // 距离底部的距离
                left: 16, // 距离左侧的距离
                child: SizedBox(
                  width: 40, // 按钮宽度
                  height: 40, // 按钮高度
                  child: FloatingActionButton(
                    heroTag: 'menuButton',
                    backgroundColor: Color(0xFFF5DEB3), // 按钮背景颜色
                    onPressed: () {
                      // 点击时执行的操作
                      controller.toggleMenu(); // 调用控制器的方法
                    },
                    child: Icon(Icons.arrow_upward), // 按钮图标
                  ),
                ),
              ),

              // 聊天框
              Positioned(
                bottom: 80, // 距离底部的距离
                left: 66, // 距离左侧的距离
                child: SizedBox(
                  width: 40, // 按钮宽度
                  height: 40, // 按钮高度
                  child: FloatingActionButton(
                    heroTag: 'chatButton',
                    backgroundColor: Color(0xFFF5DEB3), // 按钮背景颜色
                    onPressed: () {
                      // 点击时执行的操作
                      controller.toggleChatDialog(); // 调用控制器的方法
                    },
                    child: Icon(Icons.chat), // 按钮图标
                  ),
                ),
              ),

              // 棋盘居中 + Padding
              Center(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 40.0), // 增加内边距
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ChineseChessBoardWithPieces(), // 你的棋盘组件
                ),
              ),

              // 菜单展开
              Obx(
                () => controller.showMenu.value
                    ? Positioned(
                        bottom: 130,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildMenuItem('悔棋', Icons.undo, () {
                              print('点击悔棋');
                              controller.showMenu.value =
                                  !controller.showMenu.value;
                              controller.requestUndo();
                            }),
                            const SizedBox(height: 10),
                            buildMenuItem('认输', Icons.flag, () {
                              print('点击认输');
                              controller.showMenu.value =
                                  !controller.showMenu.value;
                              controller.surrender();
                            }),
                            const SizedBox(height: 10),
                            buildMenuItem('和棋', Icons.handshake, () {
                              print('点击和棋');
                              controller.showMenu.value =
                                  !controller.showMenu.value;
                              controller.requestDraw();
                            }),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // 聊天展开
              Obx(
                () => controller.showChat.value
                    ? Positioned(
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom / 2 + 130,
                        left: 66,
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF5DEB3), Color(0xFFEED7A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(2, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 顶部输入框和发送按钮
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          controller.chatInputController,
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: '输入聊天内容...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 0,
                                          horizontal: 6,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.send, color: Colors.brown),
                                    onPressed: () {
                                      controller.sendChat(
                                        controller.chatInputController.text,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // 预设对话语句
                              Container(
                                height: 100, // 控制最大高度，可调
                                margin: const EdgeInsets.only(right: 20),
                                // padding: const EdgeInsets.only(right: 5),
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  interactive: true,
                                  radius: const Radius.circular(8),
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 8,
                                      children: [
                                        chatPhraseChip('棋逢对手', () {
                                          controller.sendChat('棋逢对手');
                                        }),
                                        chatPhraseChip('手下留情', () {
                                          controller.sendChat('手下留情');
                                        }),
                                        chatPhraseChip('好棋!', () {
                                          controller.sendChat('好棋!');
                                        }),
                                        chatPhraseChip('可以快一点吗，我等得花都谢了', () {
                                          controller.sendChat('可以快一点吗，我等得花都谢了');
                                        }),
                                        chatPhraseChip('等一下,我思考下', () {
                                          controller.sendChat('等一下,我思考下');
                                        }),
                                        chatPhraseChip('一着不慎,满盘皆输', () {
                                          controller.sendChat('一着不慎,满盘皆输');
                                        }),
                                        chatPhraseChip('再来一局!', () {
                                          controller.sendChat('再来一局!');
                                        }),
                                        chatPhraseChip('真是妙手!', () {
                                          controller.sendChat('真是妙手!');
                                        }),
                                        chatPhraseChip('奇哉妙也!', () {
                                          controller.sendChat('奇哉妙也!');
                                        }),
                                        chatPhraseChip('你是职业的吗?', () {
                                          controller.sendChat('你是职业的吗?');
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              //我方聊天气泡
              Obx(
                () => controller.showMyMessage.value
                    ? Positioned(
                        bottom: 100,
                        right: 50,
                        child: SpeechBubble(
                          isMyself: true, // 尖角在右下
                          text: controller.chatInputController.text,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              //对方聊天气泡
              Obx(
                () => controller.playInfo['opponent']['showMessage'].value
                    ? Positioned(
                        top: 70,
                        left: 75,
                        child: SpeechBubble(
                          isMyself: false, // 尖角在右下
                          text: controller.opponentChatMessage.value,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
