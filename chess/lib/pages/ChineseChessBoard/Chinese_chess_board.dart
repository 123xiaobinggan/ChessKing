import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/pages/ChineseChessBoard/Chinese_chess_board_controller.dart';
import '/widgets/build_player_info_block.dart';
import '/widgets/build_menu_item.dart';
import '/widgets/speech_bubble.dart';
import '/widgets/Chinese_chess_board_piece.dart';
import '/widgets/confirm_dialog.dart';
import '/widgets/chat_panel.dart';

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
    controller.aiLevel = Get.parameters['aiLevel'] ?? '初级';
    print('type:${controller.type}');
    print('opponentAccountId:${Get.parameters['accountId']}');
    print('gameTime:${controller.gameTime.value}');
    print('stepTime:${controller.stepTime.value}');
    print('AiLevel:${controller.aiLevel}');
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
                    username:
                        controller.playerInfo['opponent']?['username']?.value ??
                        '',
                    accountId:
                        controller
                            .playerInfo['opponent']?['accountId']
                            ?.value ??
                        '',
                    level:
                        controller.playerInfo['opponent']?['level']?.value ??
                        '',
                    isMyTurn: controller.playerInfo['opponent']['myTurn'],

                    imagePath:
                        controller.playerInfo['opponent']?['avatar']?.value ??
                        'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                    isRed:
                        controller.playerInfo['opponent']?['isRed']?.value ??
                        false,
                    totalTime:
                        controller.playerInfo['opponent']?['timeLeft']?.value ??
                        0,
                    stepTime: controller.opponentStepTime.value,
                    onTap: () {
                      controller.showPersonalInfo(
                        controller.playerInfo['opponent']?['accountId']?.value,
                      );
                    },
                  ),
                ),
              ),

              // // 我的头像（左下角）
              Positioned(
                bottom: 16,
                right: 16,
                child: Obx(
                  () => buildPlayerInfoBlock(
                    username: controller.playerInfo['me']?['username'] ?? '',
                    accountId: controller.playerInfo['me']?['accountId'] ?? '',
                    level: controller.playerInfo['me']?['level'] ?? '',
                    isMyTurn: controller.playerInfo['me']['myTurn'],
                    imagePath:
                        controller.playerInfo['me']['avatar'] ??
                        'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                    isRed: controller.playerInfo['me']['isRed'].value,
                    totalTime:
                        controller.playerInfo['me']?['timeLeft']?.value ?? 0,
                    stepTime: controller.myStepTime.value,
                    onTap: () {
                      controller.showPersonalInfo(
                        controller.playerInfo['me']?['accountId'],
                      );
                    },
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
                  child: ChineseChessBoardWithPieces(),
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
                        child: ChatPanel(controller: controller),
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
                () => controller.playerInfo['opponent']['showMessage'].value
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
