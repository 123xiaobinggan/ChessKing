import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/build_game_button.dart';

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
            ),
          ),
          // 按钮区域
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildGameButton('象棋', 'assets/Level/Chinese_chess.png','ChineseChess'),
                const SizedBox(height: 50),
                buildGameButton('围棋', 'assets/Level/Go.png',''),
                const SizedBox(height: 50),
                buildGameButton('军棋', 'assets/Level/military.png',''),
                const SizedBox(height: 50),
                buildGameButton('五子', 'assets/Level/Fir.png',''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
