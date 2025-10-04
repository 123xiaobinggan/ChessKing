import 'package:flutter/material.dart';
import 'package:get/get.dart';

void ShowConversationMessage({
  required String avatar,
  required String username,
  required String content,
  required VoidCallback onTap,
}) {
  final overlay = Get.overlayContext; // 👈 全局 Overlay
  if (overlay == null) return;

  final overlayState = Overlay.of(overlay);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return _AnimatedConversationMessage(
        avatar: avatar,
        username: username,
        content: content,
        onTap: () {
          entry.remove();
          onTap();
        },
        onDismiss: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      );
    },
  );

  overlayState.insert(entry);

  // 自动消失
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

class _AnimatedConversationMessage extends StatefulWidget {
  final String avatar;
  final String username;
  final String content;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AnimatedConversationMessage({
    required this.avatar,
    required this.username,
    required this.content,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  _AnimatedConversationMessageState createState() =>
      _AnimatedConversationMessageState();
}

class _AnimatedConversationMessageState
    extends State<_AnimatedConversationMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // 从顶部滑入
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 开始进入动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;

    // 判断是否需要移除通知
    if (_dragOffset.dy < -50 || _dragOffset.dx.abs() > 50) {
      // 向上滑动超过50或横向滑动超过50则移除
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    } else {
      // 否则回到原位
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, // 避开状态栏
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            widget.onTap();
          },
          onPanStart: _handleDragStart,
          onPanUpdate: _handleDragUpdate,
          onPanEnd: _handleDragEnd,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: _dragOffset,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA67B5B),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.avatar),
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
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
