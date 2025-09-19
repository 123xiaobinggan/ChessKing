import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../global/global_data.dart'; // 导入全局数据

class GameRecordController extends GetxController {
  late String type;
  late String accountId;
  var gameRecords = [].obs; // 使用 RxList 来监听变化
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    type = Get.parameters['type'] ?? 'ChineseChess'; // 获取传递的类型
    accountId = Get.parameters['accountId'] ?? GlobalData.userInfo['accountId'];
    print('type,$type,accountId,$accountId');
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50) {
        if (type == '总览') {
          fetchGameRecords("ChineseChess");
          fetchGameRecords("Go");
          fetchGameRecords("military");
          fetchGameRecords("Fir");
          gameRecords.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        } else {
          fetchGameRecords(type);
        }
      }
    });
    if (type == '总览') {
      fetchGameRecords("ChineseChess");
      fetchGameRecords("Go");
      fetchGameRecords("military");
      fetchGameRecords("Fir");
      gameRecords.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    } else {
      fetchGameRecords(type);
    }
  }

  @override
  void onClose() {
    scrollController.dispose(); // 确保控制器被释放
    super.onClose();
  }

  Future<void> fetchGameRecords(String type) async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'accountId': accountId,
      'type': type,
      'createdAt': gameRecords.length - 1 >= 0
          ? gameRecords[gameRecords.length - 1]['createdAt']
          : DateTime.now().millisecondsSinceEpoch,
    };
    try {
      final res = await dio.post(
        '${GlobalData.url}/GetGameRecord',
        data: params,
      );

      if (res.data['code'] == 0) {
        print('获取游戏记录成功: ${res.data['records']}');

        List<dynamic> records = res.data['records'];
        if (records.isEmpty) {
          hasMore.value = false;
        }

        isLoadingMore.value = false;

        for (var record in records) {
          // 1. 确保当前用户在 player1
          if (record['player1']['accountId'] !=
              accountId) {
            var temp = record['player1'];
            record['player1'] = record['player2'];
            record['player2'] = temp;
          }

          // 2. 计算对局结果
          if (record['result']['winner'] == accountId) {
            record['result'] = "胜";
          } else if (record['result']['winner'] ==
              record['player2']['accountId']) {
            record['result'] = "败";
          } else {
            record['result'] = "和";
          }
          print('record[timeMode],${record['timeMode']}');
          record['type'] =
              translateType(record['type']) +
              " " +
              ((record['timeMode'] ?? 900) / 60).toInt().toString() +
              '分钟';

          int undo = 0;
          print('record[moves],${record['moves']}');
          // 3. 过滤 moves
          record['moves'] = (record['moves'] as List).where((move) {
            final type = move['type'] as String;
            if (move['from']['row'] == -1 && move['from']['col'] == -1) {
              if (type.contains('同意悔棋')) undo++;
              return false;
            }
            return true;
          }).toList();
          record['moves'] = record['moves'].sublist(
            0,
            record['moves'].length - undo,
          );
        }

        // 4. 更新 gameRecords
        gameRecords.addAll(records);
      }
    } catch (e) {
      print('获取游戏记录失败: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  String translateType(String type) {
    String species = '';
    String mode = '';
    if (type.contains('ChineseChess')) {
      species = '象棋';
    } else if (type.contains('Go')) {
      species = '围棋';
    } else if (type.contains('military')) {
      species = '军事';
    } else if (type.contains('Fir')) {
      species = '五子棋';
    }
    if (type.contains('Match')) {
      mode = '匹配';
    } else if (type.contains('Ai')) {
      mode = 'AI';
    } else if (type.contains('Friend')) {
      mode = '好友对战';
    } else if (type.contains('Rank')) {
      mode = '排位';
    } else {
      mode = '';
    }
    return species + " " + mode;
  }
}
