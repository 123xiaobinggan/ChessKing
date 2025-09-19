import 'package:flutter/material.dart';
import 'build_player_avatar.dart';
import 'build_time_bar.dart';
import 'package:get/get.dart';
import '/global/global_data.dart';

Widget buildPlayerInfoBlock({
  required String username,
  required String accountId,
  required String level,
  required RxBool isMyTurn,
  required String imagePath,
  required bool isRed,
  required int totalTime,
  required int stepTime,
  final Function()? onTap,
}) {
  final avatar = GestureDetector(
    onTap: onTap,
    child: AnimatedAvatar(
      imagePath: imagePath,
      isMyTurn: isMyTurn,
      isRed: isRed,
    ),
  );
  // print('isMyturn: ${isMyTurn.value}');
  final info = Column(
    crossAxisAlignment: isRed
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        username,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'ID: $accountId',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      Text(level, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );

  final timer = buildTimerBar(totalTime: totalTime, stepTime: stepTime);

  // 顺序根据 敌我方 决定
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: accountId == GlobalData.userInfo['accountId']
        ? [
            timer,
            const SizedBox(width: 15),
            info,
            const SizedBox(width: 8),
            avatar,
          ]
        : [
            avatar,
            const SizedBox(width: 8),
            info,
            const SizedBox(width: 15),
            timer,
          ],
  );
}
