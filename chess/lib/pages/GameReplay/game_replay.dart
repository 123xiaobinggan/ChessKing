import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/Chinese_chess_board_painter.dart';
import '../../widgets/Chinese_chess_piece_painter.dart';
import 'game_replay_controller.dart';
import '/widgets/build_player_info_block.dart';

class GameReplay extends StatelessWidget {
  GameReplay({super.key});
  final GameReplayController controller = Get.find();

  Widget buildBoard(String type) {
    switch (type) {
      case 'ChineseChess':
        return LayoutBuilder(
          builder: (_, constraints) {
            controller.boardWidth = constraints.maxWidth;
            controller.boardHeight = controller.boardWidth * 10 / 9;

            return GestureDetector(
              child: SizedBox(
                width: controller.boardWidth,
                height: controller.boardHeight,
                child: Obx(
                  () => Stack(
                    children: [
                      // 棋盘
                      CustomPaint(
                        // 棋盘
                        size: Size(
                          controller.boardWidth,
                          controller.boardHeight * 1.05,
                        ),
                        painter: ChineseChessPainter(),
                      ),

                      // 象棋棋子
                      Stack(
                        children: [
                          ...controller.ChineseChessPieces.map((p) {
                            final double targetLeft =
                                p.pos.col * controller.boardWidth * 0.88 / 8 +
                                1.6;
                            final double targetTop =
                                p.pos.row * controller.boardHeight * 0.889 / 9 -
                                0.5;

                            return AnimatedPositioned(
                              key: ValueKey(p),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: targetLeft,
                              top: targetTop,
                              child: ChineseChessPiece(
                                type: p.type,
                                isRed: p.isRed,
                                row: p.pos.row,
                                col: p.pos.col,
                                isSelected: controller.selectedPiece == p,
                                isPlaced: controller.placedPiece == p,
                                onTap: () {
                                  // controller.selectPiece(p);
                                },
                              ),
                            );
                          }),
                        ],
                      ),

                      // 棋子路径
                      Positioned(
                        left:
                            controller.sourcePoint.value.col *
                                controller.boardWidth *
                                0.88 /
                                8 +
                            1.6 +
                            20 / 1.414,
                        top:
                            controller.sourcePoint.value.row *
                                controller.boardHeight *
                                0.889 /
                                9 +
                            1.5 +
                            20 / 1.414,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      case 'Go':
        return Image.asset('assets/MyInfo/Go.png');
      case 'military':
        return Image.asset('assets/MyInfo/military.png');
      case 'Fir':
        return Image.asset('assets/MyInfo/Fir.png');
      default:
        return Image.asset('assets/MyInfo/ChineseChess.png');
    }
  }

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
                '对局回放',
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
          // 背景图
          SizedBox.expand(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
            ),
          ),

          // 对方头像（左上角）
          Positioned(
            top: 10,
            left: 16,
            child: Obx(() {
              if (controller.room.isEmpty) {
                return Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return buildPlayerInfoBlock(
                username: controller.room['player2']?['username'] ?? '',
                accountId: controller.room['player2']?['accountId'] ?? '',
                level: controller.room['player2']?['level'] ?? '',
                isMyTurn: false.obs,

                imagePath:
                    controller.room['player2']?['avatar'] ??
                    'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                isRed: controller.room['player2']?['isRed'] ?? false,
                totalTime: controller.room['timeMode'] ?? 0,
                stepTime: controller.room['timeMode'] == 300
                    ? 15
                    : controller.room['timeMode'] == 600
                    ? 30
                    : 60,
              );
            }),
          ),

          // 我的头像（左下角）
          Positioned(
            bottom: 16,
            right: 16,
            child: Obx(() {
              if (controller.room.isEmpty) {
                return Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return buildPlayerInfoBlock(
                username: controller.room['player1']?['username'] ?? '',
                accountId: controller.room['player1']?['accountId'] ?? '',
                level: controller.room['player1']?['level'] ?? '',
                isMyTurn: false.obs,
                imagePath:
                    controller.room['player1']['avatar'] ??
                    'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                isRed: controller.room['player1']['isRed'],
                totalTime: controller.room['timeMode'] ?? 0,
                stepTime: controller.room['timeMode'] == 300
                    ? 15
                    : controller.room['timeMode'] == 600
                    ? 30
                    : 60,
              );
            }),
          ),

          // 棋盘
          Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 40.0), // 增加内边距
              margin: const EdgeInsets.only(bottom: 10),
              child: buildBoard(controller.type),
            ),
          ),

          // 下一步
          Positioned(
            bottom: 85,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                controller.next();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade400, // 按钮背景色
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15, // 水平内边距
                  vertical: 12, // 垂直内边距
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // 圆角
                ),
                elevation: 5,
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_forward, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '下一步',
                    style: TextStyle(
                      fontSize: 14, // 字体大小
                      fontWeight: FontWeight.bold, // 字体粗细
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 上一步
          Positioned(
            bottom: 85,
            right: 130,
            child: ElevatedButton(
              onPressed: () {
                controller.prev();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade400, // 按钮背景色
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15, // 水平内边距
                  vertical: 12, // 垂直内边距
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // 圆角
                ),
                elevation: 5,
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '上一步',
                    style: TextStyle(
                      fontSize: 14, // 字体大小
                      fontWeight: FontWeight.bold, // 字体粗细
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 重新开始
          Positioned(
            bottom: 85,
            right: 244,
            child: ElevatedButton(
              onPressed: () {
                controller.restart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade400, // 按钮背景色
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15, // 水平内边距
                  vertical: 12, // 垂直内边距
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // 圆角
                ),
                elevation: 5,
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '重新开始',
                    style: TextStyle(
                      fontSize: 14, // 字体大小
                      fontWeight: FontWeight.bold, // 字体粗细
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
