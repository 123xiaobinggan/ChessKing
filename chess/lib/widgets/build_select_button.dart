import 'package:flutter/material.dart';
import '/pages/ChineseChessBoard/Chinese_chess_board_controller.dart';
import 'package:get/get.dart';

Widget buildSelectButton(String label, int minutes) {
  final ChineseChessBoardController controller = Get.find();

  // 计算步时（秒）
  int stepSeconds;
  if (minutes == 5) {
    stepSeconds = 15;
  } else if (minutes == 10) {
    stepSeconds = 30;
  } else {
    stepSeconds = 60;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: GestureDetector(
      onTap: () {
        controller.gameTime.value = minutes * 60;
        if (minutes == 5) {
          controller.stepTime.value = 15;
        } else if (minutes == 10) {
          controller.stepTime.value = 30;
        } else {
          controller.stepTime.value = 60;
        }
        print('选择了 $label');
        print('controller.stage: ${controller.stage.value}');
        controller.startMatching();
        print('controller.stage: ${controller.stage.value}');
        
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF8E1), // 浅米黄色
              Color(0xFFFFE57F), // 稍深米黄色
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.brown.withOpacity(0.15),
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.brown[800],
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.brown[300]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$stepSeconds 秒/步',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
