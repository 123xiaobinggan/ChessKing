import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/build_game_button.dart';

class ChineseChess extends StatelessWidget {
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
                '中国象棋',
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
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // 1. 普通匹配
                Padding(
                  padding: const EdgeInsets.only(right: 0, bottom: 5),
                  child: Text(
                    '普通匹配',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFFB22222), // Firebrick
                            Color(0xFFFFD700), // Gold
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0, 0, 200, 30)),
                      shadows: const [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                        Shadow(
                          offset: Offset(-1, -1),
                          blurRadius: 1,
                          color: Colors.white70, // 边缘微高光，提亮边缘
                        ),
                      ],
                    ),
                  ),
                ),
                buildGameButton(
                  '小试牛刀',
                  'assets/Chinese_chess/knife.png',
                  (){
                    Get.toNamed('/ChineseChessMatch');
                  }
                ),

                const SizedBox(height: 40),

                // 2. 排位评测
                Padding(
                  padding: const EdgeInsets.only(right: 0, bottom: 5),
                  child: Text(
                    '排位评测',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF00FFFF), // Aqua
                            Color(0xFF1E90FF), // DodgerBlue
                            Color(0xFF0000FF), // Blue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0, 0, 200, 30)),
                      shadows: const [
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                        Shadow(
                          offset: Offset(-1.0, -1.0),
                          blurRadius: 1,
                          color: Colors.white30, // 柔和蓝白边光
                        ),
                      ],
                    ),
                  ),
                ),
                buildGameButton(
                  '华山论剑',
                  'assets/Chinese_chess/hua_mountain.png',
                  (){}
                  // 'ChineseChessRank',
                ),

                const SizedBox(height: 40),

                // 3. 残局挑战
                Padding(
                  padding: const EdgeInsets.only(right: 0, bottom: 5),
                  child: Text(
                    '残局挑战',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF6A5ACD), // SlateBlue
                            Color(0xFF483D8B), // DarkSlateBlue
                            Color(0xFF8A2BE2), // BlueViolet
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0, 0, 200, 30)),
                      shadows: [
                        const Shadow(
                          offset: Offset(1.5, 1.5),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                        const Shadow(
                          offset: Offset(-1.0, -1.0),
                          blurRadius: 1,
                          color: Colors.white30, // 柔光边缘
                        ),
                      ],
                    ),
                  ),
                ),
                buildGameButton(
                  '拾级而上',
                  'assets/Chinese_chess/steps.png',
                  (){}
                  // 'ChineseChessChallenge',
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
