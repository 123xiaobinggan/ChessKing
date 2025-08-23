import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowMessageDialog extends StatelessWidget {
  final String content;

  const ShowMessageDialog({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
            color: const Color(0xFF8B4513), // 木棕色
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(-2, -2), // 高光
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 使用 Get.dialog 显示，只在屏幕中间
  static void show(String content) {
    Get.dialog(
      ShowMessageDialog(content: content),
      barrierColor: Colors.transparent, // 背景透明
      barrierDismissible: false,        // 点击外部不关闭
    );
  }

  /// 关闭
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
