import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'confirm_dialog.dart';

Widget buildFriendItem(Map friend, dynamic controller) {
  return Container(
    margin: const EdgeInsets.fromLTRB(5, 0, 5, 12),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E7), // 更浅的米色
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFA67B5B), width: 3), // 木色边框
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
        // 左侧头像 + 账号
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: GestureDetector(
                onTap: () {
                  controller.showPersonalInfo(friend['accountId']);
                },
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
            Column(
              children: [
                Text(
                  friend['accountId'] ?? '未知用户',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5C3A21),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend['online']?'在线':'离线',
                  style: TextStyle(
                    fontSize: 14,
                    color: friend['online']?Colors.green:Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ],
        ),

        // 右侧按钮
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Get.dialog(
                  ConfirmDialog(
                    content: '是否确认删除好友？',
                    confirmText: '确认',
                    cancelText: '取消',
                    onConfirm: () {
                      controller.delete(accountId: friend['accountId']);
                      print('删除 ${friend['accountId']}');
                      Get.back();
                    },
                    onCancel: () => Get.back(),
                  ),
                );
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
                '删除',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                controller.invite(accountId: friend['accountId']);
                print('邀请 ${friend['accountId']}');
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
                '进房',
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
