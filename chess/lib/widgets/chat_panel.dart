import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/widgets/chat_phrase_chip.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key, this.controller});
  final dynamic controller;
  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _switchPage(int index) {
    setState(() => _currentPage = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5DEB3), Color(0xFFEED7A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部两个 tab
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildTab("聊天", 0), _buildTab("对话记录", 1)],
          ),
          const Divider(color: Colors.brown),

          // PageView 两个面板
          SizedBox(
            height: 200, // 面板内部高度
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [_buildChatPanel(), _buildHistoryPanel()],
            ),
          ),
        ],
      ),
    );
  }

  // tab 样式
  Widget _buildTab(String text, int index) {
    final isActive = _currentPage == index;
    return GestureDetector(
      onTap: () => _switchPage(index),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.brown : Colors.black54,
        ),
      ),
    );
  }

  // 聊天面板
  Widget _buildChatPanel() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 避免撑满
        children: [
          // 输入框 + 发送按钮
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      controller: widget.controller.chatInputController,
                      maxLines: 1,
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      decoration: InputDecoration(
                        hintText: "输入聊天内容...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        suffix: Obx(
                          () => Text(
                            "${widget.controller.currentLength.value}/20",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (text) {
                        widget.controller.currentLength.value = text.length;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.brown),
                onPressed: () {
                  final text = widget.controller.chatInputController.text
                      .trim();
                  if (text.isNotEmpty) {
                    widget.controller.sendMessages(text);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 预设短语 (限制高度 + 可滚动)
          Container(
            alignment: Alignment.centerLeft, // 左对齐
            constraints: const BoxConstraints(
              maxHeight: 130, // 限制最大高度，不会太高
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6,
                runSpacing: 8,
                children: [
                  chatPhraseChip(
                    '棋逢对手',
                    () => widget.controller.sendMessages('棋逢对手'),
                  ),
                  chatPhraseChip(
                    '手下留情',
                    () => widget.controller.sendMessages('手下留情'),
                  ),
                  chatPhraseChip(
                    '好棋!',
                    () => widget.controller.sendMessages('好棋!'),
                  ),
                  chatPhraseChip(
                    '等一下,我思考下',
                    () => widget.controller.sendMessages('等一下,我思考下'),
                  ),
                  chatPhraseChip(
                    '一着不慎,满盘皆输',
                    () => widget.controller.sendMessages('一着不慎,满盘皆输'),
                  ),
                  chatPhraseChip(
                    '再来一局!',
                    () => widget.controller.sendMessages('再来一局!'),
                  ),
                  chatPhraseChip(
                    '真是妙手!',
                    () => widget.controller.sendMessages('真是妙手!'),
                  ),
                  chatPhraseChip(
                    '奇哉妙也!',
                    () => widget.controller.sendMessages('奇哉妙也!'),
                  ),
                  chatPhraseChip(
                    '你是职业的吗?',
                    () => widget.controller.sendMessages('你是职业的吗?'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 对话记录面板
  Widget _buildHistoryPanel() {
    return Obx(
      () => ListView.builder(
        itemCount: widget.controller.chatHistory.length,
        itemBuilder: (context, index) {
          final message = widget.controller.chatHistory[index];
          print('message: $message');
          return ListTile(
            leading: Text(
              '${message['accountId']}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            title: Text(message['text']),
          );
        },
      ),
    );
  }
}
