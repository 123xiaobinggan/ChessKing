import 'dart:async';
import 'package:flutter/material.dart';


class CheckWarning extends StatefulWidget {
  final VoidCallback? onClose;

  const CheckWarning({super.key, this.onClose});

  @override
  State<CheckWarning> createState() => _CheckWarningState();
}

class _CheckWarningState extends State<CheckWarning>
    with SingleTickerProviderStateMixin {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    // 先淡入
    Future.delayed(Duration.zero, () {
      setState(() => opacity = 1);
    });

    // 1.5秒后淡出并关闭
    Timer(const Duration(milliseconds: 1500), () {
      setState(() => opacity = 0);
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onClose?.call();
      });
      
    });
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
