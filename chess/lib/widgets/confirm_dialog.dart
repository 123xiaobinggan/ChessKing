import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.content,
    this.confirmText = "确定",
    this.cancelText = "取消",
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40), // 防止太宽
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF8B4513), // 木棕色边框
          width: 3,
        ),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF5DEB3), // 浅米黄
              Color(0xFFEED8AE), // 深米黄
              Color(0xFFE6C994), // 更深一点
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 5,
              offset: Offset(-3, -3), // 高光
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.brown,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWoodButton(
                  text: cancelText,
                  onPressed: onCancel,
                  isConfirm: false,
                ),
                _buildWoodButton(
                  text: confirmText,
                  onPressed: onConfirm,
                  isConfirm: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWoodButton({
    required String text,
    required VoidCallback onPressed,
    required bool isConfirm,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          style:
              ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: Colors.transparent,
                // 设置 elevation 为 0 移除阴影效果
                elevation: 0,
                // 设置阴影颜色为透明
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),

          onPressed: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: isConfirm
                    ? [const Color(0xFF8B4513), const Color(0xFF6B3410)]
                    : [const Color(0xFFCD853F), const Color(0xFFB27435)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
