import 'package:flutter/material.dart';
import 'package:project/widgets/game_result.dart';
import 'package:intl/intl.dart';

Widget buildGameRecord({
  required String type,
  required String time, // 时间戳字符串
  required String result,
  required String myAvatar,
  required String myAccountId,
  required String opponentAvatar,
  required String opponentAccountId,
  required String myLevel,
  required String opponentLevel,
  required String turns,
  required Function()? onTap,
}) {
  // 转换时间戳 -> 格式化日期
  String formatTime(String ts) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(ts));
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (e) {
      return ts; // 如果转换失败，直接显示原始字符串
    }
  }

  return GestureDetector(
    onTap: () {
      if (onTap != null) {
        onTap(); // 调用传入的回调函数
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade100, Colors.yellow.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：type 和 时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                formatTime(time),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 中间：头像 - result - 头像
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 我的信息
              Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(myAvatar),
                    radius: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    myAccountId,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    myLevel,
                    style: const TextStyle(fontSize: 11, color: Colors.brown),
                  ),
                ],
              ),

              // Result
              Column(
                children: [
                  buildResultText(result),
                  const SizedBox(height: 4),
                  Text(
                    "$turns 回合",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),

              // 对手信息
              Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(opponentAvatar),
                    radius: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opponentAccountId,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    opponentLevel,
                    style: const TextStyle(fontSize: 11, color: Colors.brown),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildResultText(String result) {
  switch (result) {
    case '胜':
      return Stack(
        children: [
          // 金色描边文字
          Text(
            '胜',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              fontFamily: 'kaiti',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.amber.shade700, // 金色描边
              shadows: [
                Shadow(
                  color: Colors.amber.shade400,
                  blurRadius: 4,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          // 内部红蓝渐变填充文字
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              '胜',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'kaiti',
                color: Colors.white, // 填充必须是白色，才会被 ShaderMask 处理
              ),
            ),
          ),
        ],
      );

    case '败':
      // 简单模仿撕裂感：用渐变+斜切的文字阴影模拟
      return Stack(
        children: [
          Text(
            '败',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              fontFamily: 'kaiti',
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade300,
                    Colors.grey.shade100,
                  ],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromLTWH(0, 0, 100, 40)),
            ),
          ),

          Positioned(
            left: 2,
            top: 2,
            child: ClipPath(
              clipper: TearClipper(),
              child: Text(
                '败',
                style: TextStyle(
                  fontSize: 42,
                  fontFamily: 'kaiti',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      );
    case '和':
    default:
      return Stack(
        alignment: Alignment.center,
        children: [
          // 金色描边文字
          Text(
            '和',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = Colors.green.shade400, // 金色
            ),
          ),
          // 渐变填充文字
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.green.shade200,
                Colors.green.shade400,
                Colors.yellow.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              '和',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 必须是白色才会显示渐变
              ),
            ),
          ),
        ],
      );
  }
}
