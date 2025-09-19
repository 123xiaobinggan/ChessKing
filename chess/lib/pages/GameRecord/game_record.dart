import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'game_record_controller.dart';
import '../../widgets/build_game_record.dart'; // 导入游戏记录项组件

class GameRecord extends StatelessWidget {
  GameRecord({super.key});
  final GameRecordController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.type = Get.parameters['type'] ?? 'ChineseChess';
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
                '${translateType(controller.type)}对局记录',
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

          // 游戏记录列表
          Obx(
            () => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.gameRecords.length + 1,
              itemBuilder: (context, index) {
                if (index < controller.gameRecords.length) {
                  final record = controller.gameRecords[index];
                  return buildGameRecord(
                    type: record['type'],
                    time: record['createdAt'].toString(),
                    result: record['result'],
                    myAvatar: record['player1']['avatar'],
                    myAccountId: record['player1']['accountId'],
                    opponentAvatar: record['player2']['avatar'],
                    opponentAccountId: record['player2']['accountId'],
                    myLevel: record['player1']['level'],
                    opponentLevel: record['player2']['level'],
                    turns: ((record['moves'].length / 2).ceil().toInt())
                        .toString(),
                    onTap: () {
                      Get.toNamed(
                        '/GameReplay',
                        parameters: {
                          'roomId': record['_id'], // 传递完整的记录数据
                          'type': record['type'],
                        },
                      );
                    },
                  );
                } else {
                  // 加载更多的提示
                  if (controller.isLoadingMore.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (!controller.hasMore.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text("没有更多数据了")),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

String translateType(String type) {
  switch (type) {
    case 'ChineseChess':
      return '象棋';
    case 'Go':
      return '围棋';
    case 'military':
      return '军事';
    case 'Fir':
      return '五子棋';
    default:
      return '所有';
  }
}
