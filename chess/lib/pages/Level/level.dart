import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/build_stat_card.dart';
import '/global/global_data.dart';
import 'level_controller.dart';

class Level extends StatelessWidget {
  Level({Key? key}) : super(key: key);
  final LevelController controller = Get.find();

  // 辅助函数，用于安全获取嵌套值
  int safeGetInt(Map<String, dynamic>? map, String key) {
    return map?[key] as int? ?? 0;
  }

  // 辅助函数，用于安全获取嵌套字符串
  String safeGetString(Map<String, dynamic>? map, String key) {
    return map?[key] as String? ?? '';
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
                '我的等级',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: const Offset(0.5, 0.5),
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
      body: Obx(() {
        final overviewStats = _calculateOverviewStats();
        final gameStats = _calculateGameStats();
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/MyInfo/BackGround.png',
                fit: BoxFit.cover,
              ),
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            if (!controller.isLoading.value)
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildStatCard(
                      title: '总览',
                      onTap: () {
                        print('进入总览历史页面');
                        Get.toNamed(
                          '/GameRecord',
                          parameters: {
                            'type': '总览',
                            'accountId': controller.accountId,
                          },
                        );
                      },
                      stats: overviewStats,
                    ),
                    const SizedBox(height: 8),
                    ...gameStats.entries.map((entry) {
                      return buildStatCard(
                        title: entry.key,
                        stats: entry.value,
                        onTap: () {
                          Get.toNamed(
                            '/GameRecord',
                            parameters: {
                              'type': translateType(entry.key),
                              'accountId': controller.accountId,
                            },
                          );
                          print('进入 ${entry.key} 历史页面');
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Map<String, dynamic> _calculateOverviewStats() {
    final ChineseChess = controller.ChineseChess;
    final Go = controller.Go;
    final Military = controller.Military;
    final Fir = controller.Fir;
    print('ChineseChess,$ChineseChess');
    final totalWins =
        (ChineseChess?['win'] ?? 0) +
        (Go?['win'] ?? 0) +
        (Military?['win'] ?? 0) +
        (Fir?['win'] ?? 0);
    final totalLosses =
        (ChineseChess?['lose'] ?? 0) +
        (Go?['lose'] ?? 0) +
        (Military?['lose'] ?? 0) +
        (Fir?['lose'] ?? 0);
    final totalGames =
        (ChineseChess?['total'] ?? 0) +
        (Go?['total'] ?? 0) +
        (Military?['total'] ?? 0) +
        (Fir?['total'] ?? 0);
    final draws = totalGames - totalWins - totalLosses;
    final winRate = totalGames == 0
        ? '0.00%'
        : '${((totalWins / totalGames) * 100).toStringAsFixed(2)}%';
    print('总览:$totalWins,$totalLosses,$totalGames,$winRate');
    return {
      'icon': 'assets/Level/overview.png',
      '等级': '',
      '胜局': totalWins,
      '败局': totalLosses,
      '和棋': draws,
      '总局数': totalGames,
      '胜率': winRate,
    };
  }

  Map<String, Map<String, dynamic>> _calculateGameStats() {
    final userInfo = GlobalData.userInfo;
    final ChineseChess = controller.ChineseChess;
    final Go = controller.Go;
    final Military = controller.Military;
    final Fir = controller.Fir;
    print('ChineseChess,$ChineseChess');
    return {
      '象棋': {
        'icon': 'assets/Level/Chinese_chess.png',
        '等级': ChineseChess?['level'] ?? '1-1',
        '胜局': ChineseChess?['win'] ?? 0,
        '败局': ChineseChess?['lose'] ?? 0,
        '和棋':
            (ChineseChess?['total'] ?? 0) -
            (ChineseChess?['win'] ?? 0) -
            (ChineseChess?['lose'] ?? 0),
        '总局数': ChineseChess?['total'] ?? 0,
        '胜率': (ChineseChess?['total'] ?? 0) == 0
            ? '0%'
            : '${((ChineseChess?['win'] ?? 0) / (ChineseChess?['total'] ?? 0) * 100).toStringAsFixed(2)}%',
      },
      '围棋': {
        'icon': 'assets/Level/Go.png',
        '等级': Go?['level'] as String? ?? '1-1',
        '胜局': Go?['win'] as int? ?? 0,
        '败局': Go?['lose'] as int? ?? 0,
        '和棋':
            (Go?['total'] as int? ?? 0) -
            (Go?['win'] as int? ?? 0) -
            (Go?['lose'] as int? ?? 0),
        '总局数': Go?['total'] as int? ?? 0,
        '胜率': (Go?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((Go?['win'] as int? ?? 0) / (userInfo['Go']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
      '军棋': {
        'icon': 'assets/Level/military.png',
        '等级': Military?['level'] as String? ?? '1-1',
        '胜局': Military?['win'] as int? ?? 0,
        '败局': Military?['lose'] as int? ?? 0,
        '和棋':
            (Military?['total'] as int? ?? 0) -
            (Military?['win'] as int? ?? 0) -
            (Military?['lose'] as int? ?? 0),
        '总局数': Military?['total'] as int? ?? 0,
        '胜率': (Military?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((Military?['win'] as int? ?? 0) / (userInfo['military']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
      '五子棋': {
        'icon': 'assets/Level/Fir.png',
        '等级': Fir?['level'] as String? ?? '1-1',
        '胜局': Fir?['win'] as int? ?? 0,
        '败局': Fir?['lose'] as int? ?? 0,
        '和棋':
            (Fir?['total'] as int? ?? 0) -
            (Fir?['win'] as int? ?? 0) -
            (Fir?['lose'] as int? ?? 0),
        '总局数': Fir?['total'] as int? ?? 0,
        '胜率': (Fir?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((Fir?['win'] as int? ?? 0) / (userInfo['Fir']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
    };
  }

  String translateType(String type) {
    print('type:$type');
    switch (type) {
      case '象棋':
        return 'ChineseChess';
      case '围棋':
        return 'Go';
      case '军棋':
        return 'military';
      case '五子棋':
        return 'Fir';
      default:
        return type;
    }
  }
}
