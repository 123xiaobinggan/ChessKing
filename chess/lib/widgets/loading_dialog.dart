import 'dart:async';
import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  final String content;

  const LoadingDialog({
    super.key,
    required this.content,
  });

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  int dotCount = 1;
  Timer? timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 点点动画
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        dotCount = (dotCount % 3) + 1;
      });
    });

    // 淡入动画
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 固定宽度，防止省略号抖动
    final maxTextWidth = _calculateTextWidth("${widget.content}...")*1.2;

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: maxTextWidth + 24 + 10 + 18 * 2, // 进度条 + 间距 + 内边距
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF5DEB3),
                Color(0xFFEED8AE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF8B4513),
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
                offset: Offset(-2, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF8B4513),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${widget.content}${'.' * dotCount}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                  decoration: TextDecoration.none, // 去掉下划线
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.brown,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
