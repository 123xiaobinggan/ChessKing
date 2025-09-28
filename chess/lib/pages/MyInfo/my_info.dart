import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'my_info_controller.dart';
import '/global/global_data.dart';
import '/app/routes/app_pages.dart';
import '/widgets/avatar_image.dart';
import '../AvatarPreview/avatar_preview.dart';

class MyInfo extends StatelessWidget {
  MyInfo({super.key});

  MyInfoController controller = Get.put(MyInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('MyInfo')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MyInfo/BackGround.png',
              fit: BoxFit.cover, // 图片填充方式
            ),
          ),
          Column(
            children: [
              // 信息卡片
              Container(
                margin: EdgeInsets.fromLTRB(20, 70, 20, 0),
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 圆形头像 + 边框
                    GestureDetector(
                      onTap: () {
                        final imageProvider = resolveImageProvider(
                          GlobalData.userInfo['avatar'] ??
                              GlobalData.userInfo['avatar'],
                          true,
                        );
                        Get.to(
                          () => ImagePreviewPage(imageProvider: imageProvider),
                        );
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Obx(
                          () =>
                              avatarImage(GlobalData.userInfo['avatar'], true),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // 用户信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          SizedBox(height: 20),
                          // username
                          Text(
                            GlobalData.userInfo['username'] ?? '用户名',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // ID
                          Text(
                            "ID: ${GlobalData.userInfo['accountId'] ?? '账号ID'}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          // 描述
                          Text(
                            GlobalData.userInfo['description'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          // ip
                          Text(
                            GlobalData.userInfo['ip'] ?? 'IP地址',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () {
                        print('Edit');
                        Get.toNamed(AppRoutes.Edit);
                      },
                    ),
                  ],
                ),
              ),
              // 状态卡片
              Container(
                margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3BBEF5), Color(0xFF6DD5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 状态栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 活跃度
                        Row(
                          children: [
                            Image.asset(
                              'assets/MyInfo/Activity.png',
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "${GlobalData.userInfo['activity']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // 金币
                        Row(
                          children: [
                            Image.asset(
                              'assets/MyInfo/Gold.png',
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "${GlobalData.userInfo['gold'] ?? '0'}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // 点券
                        Row(
                          children: [
                            Image.asset(
                              'assets/MyInfo/Coupon.png',
                              width: 22,
                              height: 22,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "${GlobalData.userInfo['coupon'] ?? '0'}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // 经验条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value:
                            (GlobalData.userInfo['activity'].toDouble() % 100) /
                            100,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    // 经验说明文字（可选）
                    Text(
                      "距离升级还有：${100 - GlobalData.userInfo['activity'] % 100}",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 功能按钮
              Expanded(
                child: Container(
                  // height: 350,
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 227, 196, 68),
                  ),
                  child: Stack(
                    children: [
                      // 选项背景
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),

                          child: Image.asset(
                            'assets/MyInfo/OptionBackGround.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // 选项按钮
                      ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 16,
                        ),
                        children: [
                          // 我的好友
                          ListTile(
                            leading: Image.asset(
                              'assets/MyInfo/Friend.png',
                              width: 24,
                              height: 24,
                            ),
                            title: Text(
                              '我的好友',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 17,
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
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 26,
                              color: Colors.brown.shade400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.brown.withValues(
                              alpha: (0.3 * 255),
                            ), // 半透明背景突出每个item
                            onTap: () {
                              Get.toNamed('/MyFriends');
                            },
                          ),
                          Divider(thickness: 2),
                          //会话列表
                          ListTile(
                            leading: Image.asset(
                              'assets/MyInfo/Message.png',
                              width: 24,
                              height: 24,
                            ),
                            title: Text(
                              '会话列表',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 17,
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
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 26,
                              color: Colors.brown.shade400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.brown.withValues(
                              alpha: (0.3 * 255),
                            ), // 半透明背景突出每个item
                            onTap: () {
                              Get.toNamed('/Messages');
                            },
                          ),
                          Divider(thickness: 2),
                          // 等级
                          ListTile(
                            leading: Image.asset(
                              'assets/MyInfo/Level.png',
                              width: 24,
                              height: 24,
                            ),
                            title: Text(
                              '我的等级',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 17,
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
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 26,
                              color: Colors.brown.shade400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.brown.withValues(
                              alpha: (0.3 * 255),
                            ), // 半透明背景突出每个item
                            onTap: () {
                              Get.toNamed(
                                '/Level',
                                parameters: {
                                  'accountId': GlobalData.userInfo['accountId'],
                                },
                              );
                            },
                          ),
                          Divider(thickness: 2),
                          // 版本发行
                          ListTile(
                            leading: Image.asset(
                              'assets/MyInfo/Version.png',
                              width: 24,
                              height: 24,
                            ),
                            title: Text(
                              '版本发行',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 17,
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
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 26,
                              color: Colors.brown.shade400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.brown.withValues(
                              alpha: (0.3 * 255),
                            ), // 半透明背景突出每个item
                            onTap: () {
                              Get.toNamed('/Version');
                            },
                          ),
                          Divider(thickness: 2),
                          // 退出登录
                          ListTile(
                            leading: Image.asset(
                              'assets/MyInfo/LogOut.png',
                              width: 24,
                              height: 24,
                            ),
                            title: Text(
                              '退出登录',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 17,
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
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 26,
                              color: Colors.brown.shade400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.brown.withValues(
                              alpha: (0.3 * 255),
                            ), // 半透明背景突出每个item
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  title: Text('退出登录'),
                                  content: Text('确定要退出登录吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back(); // 取消
                                      },
                                      child: Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        controller.logout();
                                      },
                                      child: Text('确定'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(thickness: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 悬挂铁链
          Positioned(
            top: 195, // 调整位置
            left: 90,
            right: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/MyInfo/Chain.png', width: 30, height: 30),
                Image.asset('assets/MyInfo/Chain.png', width: 30, height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
