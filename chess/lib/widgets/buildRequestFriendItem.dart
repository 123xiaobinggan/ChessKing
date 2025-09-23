import 'package:flutter/material.dart';

Widget buildRequestFriendItem(Map friend, dynamic controller) {
  return Container(
    margin: const EdgeInsets.fromLTRB(5, 0, 5, 12),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E7), // 更浅的米色
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFA67B5B), width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.brown.withValues(alpha: 0.4),
          blurRadius: 6,
          offset: const Offset(4, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 左侧头像 + accountId
        Row(
          children: [
            GestureDetector(
              onTap: () {
                controller.showPersonalInfo(friend['accountId']);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    friend['avatar'] ??
                        'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),
            Text(
              friend['accountId'] ?? '未知用户',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5C3A21),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // 右侧 拒绝 + 接受 按钮
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                controller.reject(accountId: friend['accountId']);
                print('拒绝 ${friend['accountId']}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA67B5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 1,
                minimumSize: const Size(45, 25),
              ),
              child: const Text(
                '拒绝',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                controller.accept(accountId: friend['accountId']);
                print('添加 ${friend['accountId']}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA67B5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 1,
                minimumSize: const Size(45, 25),
              ),
              child: const Text(
                '接受',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
