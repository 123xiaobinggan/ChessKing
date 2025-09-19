import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/AvatarPreview/avatar_preview.dart';
import 'avatar_image.dart';

class BuildPersonalInfoCard extends StatelessWidget {
  final String avatar;
  final String accountId;
  final String username;
  final String description;
  final int activity; // 经验
  final int gold;
  final int coupon;

  final VoidCallback onLevelTap; // 点击等级信息按钮
  final VoidCallback onFriendTap; // 点击添加好友按钮

  const BuildPersonalInfoCard({
    super.key,
    required this.avatar,
    required this.accountId,
    required this.username,
    required this.description,
    required this.activity,
    required this.gold,
    required this.coupon,
    required this.onLevelTap,
    required this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部 头像 + 基本信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 圆形头像带边框
                  GestureDetector(
                    onTap: () {
                      final imageProvider = NetworkImage(avatar);
                      Get.to(
                        () => ImagePreviewPage(imageProvider: imageProvider),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: avatarImage(avatar, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "ID: $accountId",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 三个图标：经验、金币、点券
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('assets/MyInfo/Activity.png', activity.toString()),
                  _buildStat('assets/MyInfo/Gold.png', gold.toString()),
                  _buildStat('assets/MyInfo/Coupon.png', coupon.toString()),
                ],
              ),
              const SizedBox(height: 12),

              // 等级按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onLevelTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("等级信息"),
                ),
              ),
              const SizedBox(height: 8),

              // 添加好友按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onFriendTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("添加好友"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String image, String value) {
    return Row(
      children: [
        Image.asset(image, width: 20, height: 20),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
