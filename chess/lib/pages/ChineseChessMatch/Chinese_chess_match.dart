import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/build_game_button.dart';

class ChineseChessMatch extends StatelessWidget {
  const ChineseChessMatch({Key? key}) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildGameButton(
                  '随机匹配',
                  'assets/Chinese_chess/random_match.png',
                  'ChineseChessBoard', 
                ),
                const SizedBox(height: 100), 
                buildGameButton(
                  '好友对战',
                  'assets/Chinese_chess/fight_with_friends.png',
                  'MyFriends',
                  edge:36,
                  type: 'ChineseChessFriend'
                ),
                const SizedBox(height: 100),
              ]
            )
          )
        ]
      )
    );
  }
}
