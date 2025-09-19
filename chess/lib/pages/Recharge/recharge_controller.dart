import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../global/global_data.dart';

class RechargeController extends GetxController {
  var selectedTarget = 'gold'.obs; // gold / coupon
  var goldInput = ''.obs;
  var couponInput = ''.obs;

  final goldFocus = FocusNode();
  final couponFocus = FocusNode();

  List<int> presets = [10, 20, 50, 100, 200, 500];

  @override
  void onInit() {
    super.onInit();
    goldFocus.addListener(() {
      if (goldFocus.hasFocus) {
        selectTarget('gold');
      }
    });
    couponFocus.addListener(() {
      if (couponFocus.hasFocus) {
        selectTarget('coupon');
      }
    });
  }

  void selectTarget(String target) {
    selectedTarget.value = target;
    if (target == 'gold') {
      couponFocus.unfocus();
    } else {
      goldFocus.unfocus();
    }
  }

  void applyPreset(int value) {
    if (selectedTarget.value == 'gold') {
      goldInput.value = value.toString();
    } else {
      couponInput.value = value.toString();
    }
  }

  void recharge() async {
    if ((goldInput.value.isNotEmpty &&
            !RegExp(r'^\d+$').hasMatch(goldInput.value)) ||
        (couponInput.value.isNotEmpty &&
            !RegExp(r'^\d+$').hasMatch(couponInput.value))) {
      Get.snackbar("提示", "请输入有效的正整数金额");
      return;
    }

    final gold = int.tryParse(goldInput.value) ?? 0;
    final coupon = int.tryParse(couponInput.value) ?? 0;

    if (gold == 0 && coupon == 0) {
      Get.snackbar("提示", "请输入或选择充值金额");
      return;
    }
    if (gold <= 0 && coupon <= 0) {
      Get.snackbar("提示", "请输入或选择充值金额");
      return;
    }

    // 新增验证：检查是否为正整数
    if (gold < 0 || coupon < 0) {
      Get.snackbar("提示", "充值金额必须为正整数");
      return;
    }
    print("金币: $gold, 点券: $coupon");
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'accountId': GlobalData.userInfo['accountId'],
      'gold': gold,
      'coupon': coupon,
    };
    try {
      final res = await dio.post('${GlobalData.url}/recharge', data: params);
      print(res.data);
      if (res.data['code'] == 0) {
        Get.snackbar("提示", "充值成功");
        GlobalData.userInfo['gold'] = res.data['data']['gold'];
        GlobalData.userInfo['coupon'] = res.data['data']['coupon'];
      } else {
        Get.snackbar("提示", res.data['msg']);
      }
    } catch (e) {
      Get.snackbar("提示", "充值失败");
      print(e);
    }
  }
}
