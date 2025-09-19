import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/build_game_button.dart';
import '/widgets/build_select_button.dart';
import '/widgets/build_gameType_select_button.dart';

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
                  () {
                    Get.dialog(
                      Column(
                        children: [
                          SizedBox(height: 50),
                          buildSelectButton(
                            " 5 分钟场",
                            5,
                            onTap: () {
                              Get.toNamed(
                                '/ChineseChessBoard',
                                parameters: {
                                  'type': "ChineseChessMatch",
                                  'gameTime': (5 * 60).toString(),
                                  "stepTime": 15.toString(),
                                },
                              );
                            },
                          ),
                          buildSelectButton(
                            "10 分钟场",
                            10,
                            onTap: () {
                              Get.toNamed(
                                '/ChineseChessBoard',
                                parameters: {
                                  'type': "ChineseChessMatch",
                                  'gameTime': (10 * 60).toString(),
                                  "stepTime": 30.toString(),
                                },
                              );
                            },
                          ),
                          buildSelectButton(
                            "15 分钟场",
                            15,
                            onTap: () {
                              Get.toNamed(
                                '/ChineseChessBoard',
                                parameters: {
                                  'type': "ChineseChessMatch",
                                  'gameTime': (15 * 60).toString(),
                                  "stepTime": 60.toString(),
                                },
                              );
                            },
                          ),
                          buildSelectButton(
                            "20 分钟场",
                            20,
                            onTap: () {
                              Get.toNamed(
                                '/ChineseChessBoard',
                                parameters: {
                                  'type': "ChineseChessMatch",
                                  'gameTime': (20 * 60).toString(),
                                  "stepTime": 60.toString(),
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      barrierDismissible: true,
                      barrierColor: Colors.transparent,
                    );
                  },
                ),
                const SizedBox(height: 100),
                buildGameButton(
                  '好友对战',
                  'assets/Chinese_chess/fight_with_friends.png',
                  () {
                    Get.toNamed('/MyFriends');
                  },
                  edge: 36,
                ),
                const SizedBox(height: 100),
                buildGameButton(
                  '人机对战',
                  'assets/Chinese_chess/fight_with_Ai.png',
                  () {
                    Get.dialog(
                      Column(
                        children: [
                          SizedBox(height: 480),
                          GameTypeSelectButton(
                            gameType: "初级",
                            onPressed: () {
                              Get.dialog(
                                Column(
                                  children: [
                                    const SizedBox(height: 400),
                                    buildSelectButton(
                                      " 5 分钟场",
                                      5,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (5 * 60).toString(),
                                            "stepTime": 15.toString(),
                                            "aiLevel": "初级",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "10 分钟场",
                                      10,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (10 * 60).toString(),
                                            "stepTime": 30.toString(),
                                            "aiLevel": "初级",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "15 分钟场",
                                      15,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (15 * 60).toString(),
                                            "stepTime": 60.toString(),
                                            "aiLevel": "初级",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "20 分钟场",
                                      20,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (20 * 60).toString(),
                                            "stepTime": 60.toString(),
                                            "aiLevel": "初级",
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                barrierDismissible: true,
                                barrierColor: Colors.transparent,
                              );
                            },
                          ),
                          GameTypeSelectButton(
                            gameType: "中等",
                            onPressed: () {
                              Get.dialog(
                                Column(
                                  children: [
                                    const SizedBox(height: 400),
                                    buildSelectButton(
                                      " 5 分钟场",
                                      5,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (5 * 60).toString(),
                                            "stepTime": 15.toString(),
                                            "aiLevel": "中等",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "10 分钟场",
                                      10,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (10 * 60).toString(),
                                            "stepTime": 30.toString(),
                                            "aiLevel": "中等",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "15 分钟场",
                                      15,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (15 * 60).toString(),
                                            "stepTime": 60.toString(),
                                            "aiLevel": "中等",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "20 分钟场",
                                      20,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (20 * 60).toString(),
                                            "stepTime": 60.toString(),
                                            "aiLevel": "中等",
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                barrierDismissible: true,
                                barrierColor: Colors.transparent,
                              );
                            },
                          ),
                          GameTypeSelectButton(
                            gameType: "高手",
                            onPressed: () {
                              Get.dialog(
                                Column(
                                  children: [
                                    const SizedBox(height: 400),
                                    buildSelectButton(
                                      " 5 分钟场",
                                      5,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (5 * 60).toString(),
                                            "stepTime": 15.toString(),
                                            "aiLevel": "高手",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "10 分钟场",
                                      10,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (10 * 60).toString(),
                                            "stepTime": 30.toString(),
                                            "aiLevel": "高手",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "15 分钟场",
                                      15,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (15 * 60).toString(),
                                            "stepTime": 60.toString(),
                                            "aiLevel": "高手",
                                          },
                                        );
                                      },
                                    ),
                                    buildSelectButton(
                                      "20 分钟场",
                                      20,
                                      onTap: () {
                                        Get.toNamed(
                                          '/ChineseChessBoard',
                                          parameters: {
                                            'type': "ChineseChessAi",
                                            'gameTime': (20 * 60).toString(),
                                            "stepTime": 60.toString(),
                                            "aiLevel": "高手",
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                barrierDismissible: true,
                                barrierColor: Colors.transparent,
                              );
                            },
                          ),
                        ],
                      ),
                      barrierDismissible: true,
                      barrierColor: Colors.transparent,
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
