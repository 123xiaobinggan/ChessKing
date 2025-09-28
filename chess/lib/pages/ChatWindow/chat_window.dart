import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'chat_window_controller.dart';
import '../../global/global_data.dart';

class ChatWindow extends StatefulWidget {
  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> with WidgetsBindingObserver {
  final ChatWindowController controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  bool  _isLoading = false; // 加载中标志


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  // 滚动监听器
  void _scrollListener() async {
    // 检查是否滚动到顶部并且当前未在加载
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 && 
        !_isLoading && 
        _scrollController.position.extentBefore > 0) {
      setState(() {
        _isLoading = true;
      });
      
      // 加载更多消息
      await controller.getMessages();
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 背景木板
        Positioned.fill(
          child: Image.asset('assets/MyInfo/BackGround.png', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/MyInfo/BackGround.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Obx(
                  () => AppBar(
                    title: Text(
                      controller.opponentInfo['username'].value,
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0.5, 0.5),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusScope.of(context).unfocus(); // 收起键盘
                  },
                  onVerticalDragDown: (details) {
                    FocusScope.of(context).unfocus(); // 收起键盘
                  },
                  child: Obx(
                    () => ListView.builder(
                      reverse: true,
                      controller: _scrollController, // 👈 绑定控制器
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      itemCount: controller.displayItems.length,
                      itemBuilder: (context, index) {
                        if(_isLoading && index == controller.displayItems.length - 1) {
                          return Center(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                              ),
                            ),
                          );
                        }
                        final item =
                            controller.displayItems[controller
                                    .displayItems
                                    .length -
                                1 -
                                index];
                        if (item['type'] == 'time') {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).format(item['time']),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 5, 5, 5),
                                ),
                              ),
                            ),
                          );
                        }
                        final msg = item['message'];
                        final isMine =
                            msg.senderAccountId ==
                            GlobalData.userInfo['accountId'];

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMine)
                                  GestureDetector(
                                    onTap: () {
                                      controller.showPersonalInfo(
                                        controller.opponentInfo['accountId'],
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        controller.opponentInfo['avatar'].value,
                                      ),
                                    ),
                                  ),

                                if (!isMine) const SizedBox(width: 8),

                                /// 气泡
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.7,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isMine
                                              ? [
                                                  Color(0xFFEED8AE),
                                                  Color(0xFFF5DEB3),
                                                ]
                                              : [
                                                  Color(0xFFF5DEB3),
                                                  Color(0xFFEED8AE),
                                                ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(14),
                                          topRight: const Radius.circular(14),
                                          bottomLeft: isMine
                                              ? const Radius.circular(14)
                                              : const Radius.circular(0),
                                          bottomRight: isMine
                                              ? const Radius.circular(0)
                                              : const Radius.circular(14),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(1, 2),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        msg.content,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF8B4513), // 木棕色
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                if (isMine) const SizedBox(width: 8),
                                if (isMine)
                                  GestureDetector(
                                    onTap: () {
                                      controller.showPersonalInfo(
                                        GlobalData.userInfo['accountId'],
                                      );
                                    },

                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        GlobalData.userInfo['avatar'],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              /// 底部输入框
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.1),
                    border: Border(
                      top: BorderSide(color: Colors.brown.shade300, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.textEditingController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            hintText: '输入消息...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF8B4513)),
                        onPressed: () {
                          controller.sendMessage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
