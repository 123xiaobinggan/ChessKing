import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/build_stat_card.dart';
import '/global/global_data.dart';

class Level extends StatelessWidget {
  Level({Key? key}) : super(key: key);

  // 辅助函数，用于安全获取嵌套值
  int safeGetInt(Map<String, dynamic>? map, String key) {
    return map?[key] as int? ?? 0;
  }

  // 辅助函数，用于安全获取嵌套字符串
  String safeGetString(Map<String, dynamic>? map, String key) {
    return map?[key] as String? ?? '';
  }

  final overviewStats = () {
    final userInfo = GlobalData.userInfo.value;
    final chineseChess = userInfo['ChineseChess'] as Map<String, dynamic>?;
    final go = userInfo['Go'] as Map<String, dynamic>?;
    final military = userInfo['military'] as Map<String, dynamic>?;
    final fir = userInfo['Fir'] as Map<String, dynamic>?;

    final totalWins =
        (chineseChess?['win'] as int? ?? 0) +
        (go?['win'] as int? ?? 0) +
        (military?['win'] as int? ?? 0) +
        (fir?['win'] as int? ?? 0);
    final totalLosses =
        (chineseChess?['lose'] as int? ?? 0) +
        (go?['lose'] as int? ?? 0) +
        (military?['lose'] as int? ?? 0) +
        (fir?['lose'] as int? ?? 0);
    final totalGames =
        (chineseChess?['total'] as int? ?? 0) +
        (go?['total'] as int? ?? 0) +
        (military?['total'] as int? ?? 0) +
        (fir?['total'] as int? ?? 0);
    final draws = totalGames - totalWins - totalLosses;
    final winRate = totalGames == 0
        ? '0%'
        : '${((totalWins / totalGames) * 100).toStringAsFixed(2)}%';

    return {
      'icon': 'assets/Level/overview.png',
      '等级': '',
      '胜局': totalWins,
      '败局': totalLosses,
      '和棋': draws,
      '总局数': totalGames,
      '胜率': winRate,
    };
  }();

  final Map<String, Map<String, dynamic>> gameStats = () {
    final userInfo = GlobalData.userInfo.value;
    return {
      '象棋': {
        'icon': 'assets/Level/Chinese_chess.png',
        '等级': userInfo['ChineseChess']?['level'] as String? ?? '1-1',
        '胜局': userInfo['ChineseChess']?['win'] as int? ?? 0,
        '败局': userInfo['ChineseChess']?['lose'] as int? ?? 0,
        '和棋':
            (userInfo['ChineseChess']?['total'] as int? ?? 0) -
            (userInfo['ChineseChess']?['win'] as int? ?? 0) -
            (userInfo['ChineseChess']?['lose'] as int? ?? 0),
        '总局数': userInfo['ChineseChess']?['total'] as int? ?? 0,
        '胜率': (userInfo['ChineseChess']?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((userInfo['ChineseChess']?['win'] as int? ?? 0) / (userInfo['ChineseChess']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
      '围棋': {
        'icon': 'assets/Level/Go.png',
        '等级': userInfo['Go']?['level'] as String? ?? '1-1',
        '胜局': userInfo['Go']?['win'] as int? ?? 0,
        '败局': userInfo['Go']?['lose'] as int? ?? 0,
        '和棋':
            (userInfo['Go']?['total'] as int? ?? 0) -
            (userInfo['Go']?['win'] as int? ?? 0) -
            (userInfo['Go']?['lose'] as int? ?? 0),
        '总局数': userInfo['Go']?['total'] as int? ?? 0,
        '胜率': (userInfo['Go']?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((userInfo['Go']?['win'] as int? ?? 0) / (userInfo['Go']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
      '军棋': {
        'icon': 'assets/Level/military.png',
        '等级': userInfo['military']?['level'] as String? ?? '1-1',
        '胜局': userInfo['military']?['win'] as int? ?? 0,
        '败局': userInfo['military']?['lose'] as int? ?? 0,
        '和棋':
            (userInfo['military']?['total'] as int? ?? 0) -
            (userInfo['military']?['win'] as int? ?? 0) -
            (userInfo['military']?['lose'] as int? ?? 0),
        '总局数': userInfo['military']?['total'] as int? ?? 0,
        '胜率': (userInfo['military']?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((userInfo['military']?['win'] as int? ?? 0) / (userInfo['military']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
      '五子棋': {
        'icon': 'assets/Level/Fir.png',
        '等级': userInfo['Fir']?['level'] as String? ?? '1-1',
        '胜局': userInfo['Fir']?['win'] as int? ?? 0,
        '败局': userInfo['Fir']?['lose'] as int? ?? 0,
        '和棋':
            (userInfo['Fir']?['total'] as int? ?? 0) -
            (userInfo['Fir']?['win'] as int? ?? 0) -
            (userInfo['Fir']?['lose'] as int? ?? 0),
        '总局数': userInfo['Fir']?['total'] as int? ?? 0,
        '胜率': (userInfo['Fir']?['total'] as int? ?? 0) == 0
            ? '0%'
            : '${((userInfo['Fir']?['win'] as int? ?? 0) / (userInfo['Fir']?['total'] as int? ?? 0) * 100).toStringAsFixed(2)}%',
      },
    };
  }();

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildStatCard(title: '总览', onTap: () {}, stats: overviewStats),
                const SizedBox(height: 8),
                ...gameStats.entries.map((entry) {
                  return buildStatCard(
                    title: entry.key,
                    stats: entry.value,
                    onTap: () {
                      // TODO: 跳转历史页面，比如 Get.toNamed('/history/${entry.key}');
                      print('进入 ${entry.key} 历史页面');
                    },
                  );
                }).toList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
