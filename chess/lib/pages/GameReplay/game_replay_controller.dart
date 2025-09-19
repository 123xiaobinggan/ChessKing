import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../global/global_data.dart';
import '../../widgets/Chinese_chess_Piece_painter.dart';
import '../../widgets/show_message_dialog.dart';

class GameReplayController extends GetxController {
  String type = 'ChineseChess';
  String roomId = '';
  var boardWidth = 0.0;
  var boardHeight = 0.0;
  RxMap<String, dynamic> room = <String, dynamic>{}.obs; // 游戏记录数据
  // 象棋棋子数据
  RxList<ChineseChessPieceModel> ChineseChessPieces =
      <ChineseChessPieceModel>[].obs;
  Rx<ChineseChessPieceModel> selectedPiece = ChineseChessPieceModel(
    type: '',
    isRed: false,
    pos: Point(row: -1, col: -1),
  ).obs;
  Rx<ChineseChessPieceModel> placedPiece = ChineseChessPieceModel(
    type: '',
    isRed: false,
    pos: Point(row: -1, col: -1),
  ).obs;
  Rx<Point> sourcePoint = Point(row: -1, col: -1).obs;
  int step = -1;

  @override
  void onInit() async {
    super.onInit();
    type = translateType(Get.parameters['type'] ?? '象棋'); // 获取传递的类型
    roomId = Get.parameters['roomId'] ?? ''; // 获取传递的类型
    print('type,$type,roomId,$roomId');
    await fetchGameReplay();
    initPieces();
  }

  Future<void> fetchGameReplay() async {
    Dio dio = Dio();
    Map<String, dynamic> params = {'roomId': roomId};
    try {
      final res = await dio.post(
        '${GlobalData.url}/GetGameReplay',
        data: params,
      );

      if (res.data['code'] == 0) {
        room.value = res.data['room'];
        print('获取游戏记录成功: ${room}');
        // 1. 确保我在 player1
        if (room['player1']['accountId'] != GlobalData.userInfo['accountId']) {
          var temp = room['player1'];
          room['player1'] = room['player2'];
          room['player2'] = temp;
        }
        // 2. 过滤 moves
        List moves = room['moves'] as List;

        // 只保留有效落子（去掉非落子）
        moves = moves
            .where(
              (move) =>
                  !(move['from']['row'] == -1 && move['from']['col'] == -1),
            )
            .toList();

        // 处理悔棋（找到 "同意悔棋" 以及它前一步，一并删除）
        for (int i = moves.length - 1; i >= 0; i--) {
          if (moves[i]['type'] == "同意悔棋") {
            if (i > 0) {
              moves.removeAt(i - 1); // 删除前一步
              i--; // 因为前一步已删，跳过
            }
            moves.removeAt(i); // 删除“同意悔棋”
          }
        }

        room['moves'] = moves;
      } else {
        print('获取游戏记录失败: ${res.data['msg']}');
      }
    } catch (e) {
      print('获取游戏记录失败: $e');
    }
  }

  // 初始化棋子
  void initPieces() {
    ChineseChessPieces.clear();
    if (type == 'ChineseChess') {
      print('init ChineseChessPieces');
      ChineseChessPieces.addAll([
        // 上方
        ChineseChessPieceModel(
          type: '車',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 0),
        ),
        ChineseChessPieceModel(
          type: '馬',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 1),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '相' : '象',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 2),
        ),
        ChineseChessPieceModel(
          type: '仕',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 3),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '帥' : '將',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 4),
        ),
        ChineseChessPieceModel(
          type: '仕',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 5),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '相' : '象',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 6),
        ),
        ChineseChessPieceModel(
          type: '馬',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 7),
        ),
        ChineseChessPieceModel(
          type: '車',
          isRed: room['player2']['isRed'],
          pos: Point(row: 0, col: 8),
        ),
        ChineseChessPieceModel(
          type: '炮',
          isRed: room['player2']['isRed'],
          pos: Point(row: 2, col: 1),
        ),
        ChineseChessPieceModel(
          type: '炮',
          isRed: room['player2']['isRed'],
          pos: Point(row: 2, col: 7),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '兵' : '卒',
          isRed: room['player2']['isRed'],
          pos: Point(row: 3, col: 0),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '兵' : '卒',
          isRed: room['player2']['isRed'],
          pos: Point(row: 3, col: 2),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '兵' : '卒',
          isRed: room['player2']['isRed'],
          pos: Point(row: 3, col: 4),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '兵' : '卒',
          isRed: room['player2']['isRed'],
          pos: Point(row: 3, col: 6),
        ),
        ChineseChessPieceModel(
          type: room['player2']['isRed'] ? '兵' : '卒',
          isRed: room['player2']['isRed'],
          pos: Point(row: 3, col: 8),
        ),

        // 下方
        ChineseChessPieceModel(
          type: '車',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 0),
        ),
        ChineseChessPieceModel(
          type: '馬',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 1),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '相' : '象',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 2),
        ),
        ChineseChessPieceModel(
          type: '仕',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 3),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '帥' : '將',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 4),
        ),
        ChineseChessPieceModel(
          type: '仕',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 5),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '相' : '象',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 6),
        ),
        ChineseChessPieceModel(
          type: '馬',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 7),
        ),
        ChineseChessPieceModel(
          type: '車',
          isRed: room['player1']['isRed'],
          pos: Point(row: 9, col: 8),
        ),
        ChineseChessPieceModel(
          type: '炮',
          isRed: room['player1']['isRed'],
          pos: Point(row: 7, col: 1),
        ),
        ChineseChessPieceModel(
          type: '炮',
          isRed: room['player1']['isRed'],
          pos: Point(row: 7, col: 7),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '兵' : '卒',
          isRed: room['player1']['isRed'],
          pos: Point(row: 6, col: 0),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '兵' : '卒',
          isRed: room['player1']['isRed'],
          pos: Point(row: 6, col: 2),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '兵' : '卒',
          isRed: room['player1']['isRed'],
          pos: Point(row: 6, col: 4),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '兵' : '卒',
          isRed: room['player1']['isRed'],
          pos: Point(row: 6, col: 6),
        ),
        ChineseChessPieceModel(
          type: room['player1']['isRed'] ? '兵' : '卒',
          isRed: room['player1']['isRed'],
          pos: Point(row: 6, col: 8),
        ),
      ]);
    }
  }

  // 下一步
  void next() {
    step++;
    if (step < room['moves'].length) {
      var move = jsonDecode(jsonEncode(room['moves'][step]));
      print('move,$move');
      // 扭转坐标
      if (move['accountId'] == room['player2']['accountId']) {
        move['from']['row'] = 9 - move['from']['row'];
        move['from']['col'] = 8 - move['from']['col'];
        move['to']['row'] = 9 - move['to']['row'];
        move['to']['col'] = 8 - move['to']['col'];
      }
      // 找到selectedPiece
      for (var piece in ChineseChessPieces) {
        if (move['from']['row'] == piece.pos.row &&
            move['from']['col'] == piece.pos.col) {
          selectedPiece.value = piece;
          break;
        }
      }
      // 记录sourcePoint
      sourcePoint.value = Point(
        row: selectedPiece.value.pos.row,
        col: selectedPiece.value.pos.col,
      );
      placedPiece.value = selectedPiece.value;
      ChineseChessPieces.removeWhere(
        (p) => p.pos.row == move['to']['row'] && p.pos.col == move['to']['col'],
      );
      selectedPiece.value.pos.row = move['to']['row'];
      selectedPiece.value.pos.col = move['to']['col'];
    } else {
      step--;
      Get.dialog(
        ShowMessageDialog(content: '这是最后一步了'),
        barrierColor: Colors.transparent,
        barrierDismissible: false,
      );
      Future.delayed(Duration(seconds: 1), () {
        Get.back();
      });
    }
  }

  // 上一步
  void prev() {
    print('step: $step');
    if (step < 0) {
      return;
    }
    var move = jsonDecode(jsonEncode(room['moves'][step]));
    // 扭转坐标
    if (move['accountId'] == room['player2']['accountId']) {
      move['from']['row'] = 9 - move['from']['row'];
      move['from']['col'] = 8 - move['from']['col'];
      move['to']['row'] = 9 - move['to']['row'];
      move['to']['col'] = 8 - move['to']['col'];
    }
    if (move['capture'] != null && room['player1']['isRed'] == false) {
      move['capture']['pos']['row'] = 9 - move['capture']['pos']['row'];
      move['capture']['pos']['col'] = 8 - move['capture']['pos']['col'];
    }
    selectedPiece.value.pos.row = move['from']['row'];
    selectedPiece.value.pos.col = move['from']['col'];
    placedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: true,
      pos: Point(row: -1, col: -1),
    );
    selectedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: true,
      pos: Point(row: -1, col: -1),
    );

    sourcePoint.value = Point(row: -1, col: -1);
    if (move['capture'] != null) {
      ChineseChessPieces.add(
        ChineseChessPieceModel(
          type: move['capture']['type'],
          isRed: move['capture']['isRed'],
          pos: Point(
            row: move['capture']['pos']['row'],
            col: move['capture']['pos']['col'],
          ),
        ),
      );
    }
    step--;
    if (step >= 0) {
      var lastmove = jsonDecode(jsonEncode(room['moves'][step]));
      // 扭转坐标
      if (lastmove['accountId'] == room['player2']['accountId']) {
        lastmove['from']['row'] = 9 - lastmove['from']['row'];
        lastmove['from']['col'] = 8 - lastmove['from']['col'];
        lastmove['to']['row'] = 9 - lastmove['to']['row'];
        lastmove['to']['col'] = 8 - lastmove['to']['col'];
      }
      sourcePoint.value = Point(
        row: lastmove['from']['row'],
        col: lastmove['from']['col'],
      );
      for (var piece in ChineseChessPieces) {
        if (piece.pos.row == lastmove['to']['row'] &&
            piece.pos.col == lastmove['to']['col']) {
          selectedPiece.value = piece;
          placedPiece.value = piece;
          break;
        }
      }
    }
  }

  // 重置
  void restart() {
    step = -1;
    selectedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: true,
      pos: Point(row: -1, col: -1),
    );
    placedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: true,
      pos: Point(row: -1, col: -1),
    );
    sourcePoint.value = Point(row: -1, col: -1);
    initPieces();
  }

  String translateType(String type) {
    if (type.contains('象棋')) {
      return 'ChineseChess';
    } else if (type.contains('围棋')) {
      return 'Go';
    } else if (type.contains('军棋')) {
      return 'military';
    } else if (type.contains('五子棋')) {
      return 'Fir';
    } else {
      return 'ChineseChess';
    }
  }
}
