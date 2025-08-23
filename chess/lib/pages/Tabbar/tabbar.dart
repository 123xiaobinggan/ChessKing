import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'tabbar_controller.dart';
import '../Index/Index.dart';
import '../MyInfo/my_info.dart';

class Tabbar extends StatelessWidget {
  Tabbar({super.key});

  final List<Widget> pages = [Index(), MyInfo()];
  TabbarController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/MyInfo/BackGround.png',
                fit: BoxFit.cover, // 图片填充方式
              ),
            ),
            BottomNavigationBar(
              backgroundColor: Colors.transparent, // 底部导航栏背景透明,
              currentIndex: controller.currentIndex.value,
              unselectedItemColor: Colors.white,
              selectedItemColor: const Color.fromARGB(255, 77, 23, 224),
              onTap: (index) {
                controller.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/tabbar/Index.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  activeIcon: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(66, 191, 187, 187),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),

                    child: Image.asset(
                      'assets/tabbar/IndexActive.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  label: "弈棋",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/tabbar/MyInfo.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  activeIcon: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(66, 191, 187, 187),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),

                    child: Image.asset(
                      'assets/tabbar/MyInfoActive.png',
                      width: 36,
                      height: 36,
                    ),
                  ),

                  label: "我的",
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
