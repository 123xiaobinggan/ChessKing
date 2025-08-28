import 'package:flutter/material.dart';
import '/widgets/build_game_button.dart';
import 'package:get/get.dart';

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
                buildGameButton('象棋', 'assets/Level/Chinese_chess.png', 
                   () {
                    Get.toNamed('/ChineseChess'); // 跳转到象棋页面
                  },
                ),
                const SizedBox(height: 50),
                buildGameButton('围棋', 'assets/Level/Go.png', (){
                  // Get.toNamed('/Go'); // 跳转到围棋页面
                }),
                const SizedBox(height: 50),
                buildGameButton('军棋', 'assets/Level/military.png', (){
                  // Get.toNamed('/Military'); // 跳转到军棋页面
                }),
                const SizedBox(height: 50),
                buildGameButton('五子', 'assets/Level/Fir.png', (){
                  // Get.toNamed('/Five'); // 跳转到五子棋页面
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
