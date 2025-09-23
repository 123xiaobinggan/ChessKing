import 'package:flutter/material.dart';

class InviteDialog extends StatelessWidget {
  final String avatar;
  final String accountId;
  final String username;
  final String type;
  final String gameTime; // 局时
  final String stepTime; // 步时
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const InviteDialog({
    super.key,
    required this.avatar,
    required this.accountId,
    required this.username,
    required this.type,
    required this.gameTime,
    required this.stepTime,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF5DEB3), // 浅米黄
              Color(0xFFEED8AE), // 深米黄
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Color(0xFF8B4513), // 木棕色
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 4,
              offset: Offset(-2, -2), // 高光
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 改为居中
          children: [
            // 顶部：头像 + accountId/username
            Row(
              mainAxisSize: MainAxisSize.min, // 内容宽度自适应
              children: [
                Container(
                  margin: const EdgeInsets.only(left:12),
                  padding: const EdgeInsets.all(2), // 边框宽度
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white, // 边框颜色
                      width: 2, // 边框宽度
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 30,
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.brown,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        'ID: $accountId',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.brown,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 中间文字框，带左上角 type
            Stack(
              children: [
                Container(
                  width: double.infinity, // 撑满可用宽度
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5DEB3), Color(0xFFEED8AE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Color(0xFF8B4513), width: 2),
                  ),
                  child: const Text(
                    "向你发出挑战",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: 20, // 因为左右margin=12，这里适当右移一点避免贴边
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 底部：局时、步时
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "局时: $gameTime",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.brown,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "步时: $stepTime",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.brown,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 按钮：接受 / 拒绝
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onReject,
                  child: const Text("拒绝"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onAccept,
                  child: const Text("接受"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
