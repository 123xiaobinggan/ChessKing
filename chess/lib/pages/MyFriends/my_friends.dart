import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_friends_controller.dart'; // 导入控制器类
import '/widgets/buildFriendItem.dart';
import '/widgets/buildRequestFriendItem.dart';

class MyFriends extends StatefulWidget {
  MyFriends({super.key});

  @override
  State<MyFriends> createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriends> {
  final MyFriendsController controller = Get.find(); // 实例化控制器类
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            AppBar(
              title: Text(
                '我的好友',
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
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover, // 图片填充方式
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 15),
            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7), // 更浅的米色
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFA67B5B), // 木色边框
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      // 好友列表
                      RefreshIndicator(
                        onRefresh: controller.refreshFriends, // 刷新方法
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '好友列表',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C3A21),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Obx(() {
                                if (controller.friends.isEmpty) {
                                  // 空列表时也用可滚动组件
                                  return ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(
                                            height: 200,
                                          ), // 给点高度方便拖拽
                                          const Center(
                                            child: Text(
                                              '好友列表为空，快去扩列吧',
                                              style: TextStyle(
                                                color: Color(0xFF5C3A21),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: controller.friends.length,
                                  itemBuilder: (context, index) {
                                    final friend = controller.friends[index];

                                    return buildFriendItem(friend, controller);
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      // 搜索好友
                      Column(
                        children: [
                          // 搜索好友标题
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '搜索好友',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C3A21),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              bottom: 8.0,
                            ),
                            child: TextField(
                              controller: controller.searchController,
                              decoration: InputDecoration(
                                hintText: '搜索好友',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {
                                    controller.search();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Obx(() {
                              if (controller.displayList.isEmpty) {
                                return Center(
                                  child: Text(
                                    '未找到相关好友',
                                    style: TextStyle(
                                      color: Color(0xFF5C3A21),
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: controller.displayList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.fromLTRB(
                                      5,
                                      0,
                                      5,
                                      12,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E7), // 更浅的米色
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Color(0xFFA67B5B),
                                        width: 3,
                                      ), // 木色边框
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.brown.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 6,
                                          offset: Offset(4, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween, // 让文字和按钮分散两端
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  controller
                                                          .displayList[index]['avatar'] ??
                                                      'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              controller
                                                      .displayList[index]['accountId'] ??
                                                  '未知用户',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF5C3A21),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.request(
                                              accountId: controller
                                                  .displayList[index]['accountId'],
                                            );
                                            print(
                                              '添加 ${controller.displayList[index]['accountId']}',
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFA67B5B,
                                            ), // 木质色
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                              vertical: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            elevation: 1,
                                            minimumSize: const Size(60, 30),
                                          ),
                                          child: const Text(
                                            '添加',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                      // 好友申请
                      RefreshIndicator(
                        onRefresh: controller.refreshFriends, // 刷新方法
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '申请列表',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C3A21),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Obx(() {
                                if (controller.requestFriends.isEmpty) {
                                  // 空列表时也用可滚动组件
                                  return ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(
                                            height: 200,
                                          ), // 给点高度方便拖拽
                                          const Center(
                                            child: Text(
                                              '暂无申请消息',
                                              style: TextStyle(
                                                color: Color(0xFF5C3A21),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: controller.requestFriends.length,
                                  itemBuilder: (context, index) {
                                    final friend =
                                        controller.requestFriends[index];

                                    return buildRequestFriendItem(
                                      friend,
                                      controller,
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 新增：PageView 指示器
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Color(0xFFA67B5B)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
