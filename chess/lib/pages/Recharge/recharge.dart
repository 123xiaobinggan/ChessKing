import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global/global_data.dart';
import 'recharge_controller.dart';

class Recharge extends StatelessWidget {
  Recharge({super.key});

  final RechargeController controller = Get.find();

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
                '充值中心',
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
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                buildTargetCard(
                  title: "金币",
                  target: "gold",
                  iconPath: "assets/MyInfo/Gold.png",
                  balance: GlobalData.userInfo['gold'] ?? 0,
                  inputValue: controller.goldInput,
                  focusNode: controller.goldFocus,
                ),
                const SizedBox(height: 16),
                buildTargetCard(
                  title: "点券",
                  target: "coupon",
                  iconPath: "assets/MyInfo/Coupon.png",
                  balance: GlobalData.userInfo['coupon'] ?? 0,
                  inputValue: controller.couponInput,
                  focusNode: controller.couponFocus,
                ),
                const SizedBox(height: 24),

                // 预设金额
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "可选金额",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.presets.map((amount) {
                    return GestureDetector(
                      onTap: () => controller.applyPreset(amount),
                      child: Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade600.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$amount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

                // 充值按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.recharge,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.brown.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "立即充值",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTargetCard({
    required String title,
    required String target,
    required String iconPath,
    required int balance,
    required RxString inputValue,
    required FocusNode focusNode,
  }) {
    return Obx(() {
      final isSelected = controller.selectedTarget.value == target;
      return GestureDetector(
        onTap: () => controller.selectTarget(target),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.brown.shade500.withOpacity(0.8)
                : Colors.brown.shade300.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.yellow, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：icon + 余额
              Row(
                children: [
                  Image.asset(iconPath, width: 28, height: 28),
                  const SizedBox(width: 8),
                  Text(
                    "$balance $title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 第二行：自定义充值
              Row(
                children: [
                  const Text(
                    "自定义充值",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller:
                            TextEditingController(text: inputValue.value)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: inputValue.value.length),
                              ),
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => inputValue.value = val,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      controller.selectTarget(target);
                      FocusScope.of(Get.context!).requestFocus(focusNode);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
