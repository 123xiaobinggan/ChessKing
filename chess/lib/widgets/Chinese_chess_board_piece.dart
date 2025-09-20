import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Chinese_chess_piece_painter.dart';
import 'Chinese_chess_board_painter.dart';
import '/pages/ChineseChessBoard/Chinese_chess_board_controller.dart';
import '/widgets/drum.dart';
import '/widgets/build_matching_word.dart';
import 'send_king_alert.dart';
import 'check_alert.dart';
import 'check_mate_alert.dart';
import 'game_result.dart';

class ChineseChessBoardWithPieces extends StatelessWidget {
  final ChineseChessBoardController controller = Get.find();

  ChineseChessBoardWithPieces({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final boardWidth = constraints.maxWidth;
        final boardHeight = boardWidth * 10 / 9;

        return GestureDetector(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(
              children: [
                // 棋盘
                CustomPaint(
                  // 棋盘
                  size: Size(boardWidth, boardHeight * 1.05),
                  painter: ChineseChessPainter(),
                ),

                // 状态
                Obx(() {
                  switch (controller.stage.value) {
                    case GameStage.idle:
                      return Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 50),
                            textStyle: TextStyle(fontSize: 20),
                          ),
                          onPressed: controller.startMatching,
                          child: Text("开始对弈"),
                        ),
                      );

                    case GameStage.matching:
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const DrumAnimation(),
                            const SizedBox(height: 20),
                            MatchingText(),
                          ],
                        ),
                      );

                    case GameStage.playing:
                      return Stack(
                        children: [
                          // 棋子
                          ...controller.pieces.map((p) {
                            final double targetLeft =
                                p.pos.col * boardWidth * 0.88 / 8 + 1.6;
                            final double targetTop =
                                p.pos.row * boardHeight * 0.889 / 9 - 0.5;

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
                                isSelected: controller.selectedPiece.value == p,
                                isPlaced: controller.placedPiece.value == p,
                                onTap: () {
                                  controller.selectPiece(p);
                                },
                              ),
                            );
                          }),

                          // 棋子路径
                          Positioned(
                            left:
                                controller.sourcePoint.value.col *
                                    boardWidth *
                                    0.88 /
                                    8 +
                                1.6 +
                                20 / 1.414,
                            top:
                                controller.sourcePoint.value.row *
                                    boardHeight *
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          // 绿色可移动点
                          ...controller.availableMove.map((p) {
                            const double visualSize = 12; // 视觉圈圈大小
                            const double hitSize = 40; // 点击范围大小

                            // 原本计算的位置 (针对视觉圈圈的左上角)
                            final left =
                                p.col * boardWidth * 0.88 / 8 +
                                1.6 +
                                20 / 1.414;
                            final top =
                                p.row * boardHeight * 0.889 / 9 +
                                1.5 +
                                20 / 1.414;

                            return Positioned(
                              // 调整偏移：让大区域的中心对齐小圈圈的中心
                              left: left - (hitSize - visualSize) / 2,
                              top: top - (hitSize - visualSize) / 2,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  controller.moveSelectedPiece(p.row, p.col);
                                },
                                child: Container(
                                  width: hitSize,
                                  height: hitSize,
                                  alignment: Alignment.center, // 保证小圈圈居中
                                  color: Colors.transparent,
                                  child: Container(
                                    width: visualSize,
                                    height: visualSize,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );

                    case GameStage.over:
                      return Stack(
                        children: [
                          // 棋子
                          ...controller.pieces.map((p) {
                            final double targetLeft =
                                p.pos.col * boardWidth * 0.88 / 8 + 1.6;
                            final double targetTop =
                                p.pos.row * boardHeight * 0.889 / 9 - 0.5;

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
                                isSelected: controller.selectedPiece.value == p,
                                isPlaced: controller.placedPiece.value == p,
                                onTap: () {
                                  controller.selectPiece(p);
                                },
                              ),
                            );
                          }),

                          // 棋子路径
                          Positioned(
                            left:
                                controller.sourcePoint.value.col *
                                    boardWidth *
                                    0.88 /
                                    8 +
                                1.6 +
                                20 / 1.414,
                            top:
                                controller.sourcePoint.value.row *
                                    boardHeight *
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          // 绿色可移动点
                          ...controller.availableMove.map(
                            (p) => Positioned(
                              left:
                                  p.col * boardWidth * 0.88 / 8 +
                                  1.6 +
                                  20 / 1.414,
                              top:
                                  p.row * boardHeight * 0.889 / 9 +
                                  1.5 +
                                  20 / 1.414,
                              child: GestureDetector(
                                onTap: () {
                                  controller.moveSelectedPiece(p.row, p.col);
                                },
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          GameResultOverlay(
                            result: controller.result,
                            me: controller.playInfo['me'],
                            opponent: controller.playInfo['opponent'],
                            type: controller.type.contains('ChineseChess')
                                ? 'ChineseChess'
                                : '',
                            onRestart: () => controller.startMatching(),
                          ),
                        ],
                      );
                  }
                }),

                // 将军提示
                Positioned.fill(
                  child: CheckAlertOverlay(
                    isInCheckNotifier: controller.isInCheckNotifier,
                  ),
                ),

                // 送将提示
                Obx(
                  () => controller.sendKingAlert.value
                      ? CheckWarning(
                          onClose: () => controller.sendKingAlert.value = false,
                        )
                      : SizedBox.shrink(),
                ),

                // 绝杀提示
                Positioned.fill(
                  child: CheckmateAlert(
                    isInCheckMateNotifier: controller.isInCheckMateNotifier,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
