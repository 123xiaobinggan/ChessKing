import 'dart:async';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CheckWarning extends StatefulWidget {
  final VoidCallback? onClose;

  CheckWarning({super.key, this.onClose});

  @override
  State<CheckWarning> createState() => _CheckWarningState();
}

class _CheckWarningState extends State<CheckWarning>
    with SingleTickerProviderStateMixin {
  double opacity = 0;
  Timer? _timer;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();

    // 先淡入
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() => opacity = 1);
      }
    });

    // 1.5秒后淡出并关闭
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => opacity = 0);
        _closeTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onClose?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.transparent, // 半透明背景
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x80000000),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Text(
                  "不可送将",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
