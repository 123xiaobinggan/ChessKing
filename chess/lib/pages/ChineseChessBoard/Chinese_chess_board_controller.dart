import 'dart:math';
import 'package:flutter/material.dart';
import '/widgets/Chinese_chess_piece_painter.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '/global/global_data.dart';
import '/widgets/loading_dialog.dart';
import '/widgets/confirm_dialog.dart';
import '/widgets/show_message_dialog.dart';

class ChineseChessBoardController extends GetxController {
  String type = 'ChineseChessMatch'; // 游戏类型
  String opponentAccountId = '空座';
  RxBool showMenu = false.obs; // 菜单按钮
  RxBool showChat = false.obs; // 聊天按钮
  RxBool showMyMessage = false.obs; // 控制我方聊天显示
  RxString opponentChatMessage = ''.obs; // 聊天消息

  RxBool sendKingAlert = false.obs; // 是否送将
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

  late List<List<dynamic>> chessBoard; // 记录棋盘棋子位置

  Rx<Point> sourcePoint = Point(row: -1, col: -1).obs; // 记录棋子移动前的位置

  RxList<Point> availableMove = <Point>[].obs; // 记录可移动点

  // 游戏信息
  RxMap<String, dynamic> playInfo = {
    "me": {
      "accountId": GlobalData.userInfo['accountId'],
      'username': GlobalData.userInfo['username'],
      'avatar': GlobalData.userInfo['avatar'],
      'level': GlobalData.userInfo['ChineseChess']['level'],
      'remaining_time': 0.obs,
      'myTurn': false.obs,
      'showMessage': false.obs,
      'isRed': true, // 红方
    },
    "opponent": {
      "accountId": '空座'.obs,
      'username': '空座'.obs,
      'avatar':
          'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png'
              .obs,
      'level': '1-1'.obs,
      'remaining_time': 0.obs,
      'showMessage': false.obs,
      'myTurn': false.obs,
      'isRed': false, // 黑方
    },
  }.obs;

  // 棋子
  RxList<ChineseChessPieceModel> pieces = <ChineseChessPieceModel>[].obs;
  final chatInputController = TextEditingController();

  var stage = GameStage.idle.obs; // 游戏阶段
  RxInt gameTime = 0.obs;
  RxInt stepTime = 0.obs;
  RxInt myStepTime = 0.obs;
  RxInt opponentStepTime = 0.obs;
  String result = '和';
  String roomId = '';
  final moves = [];
  int requestUndoCnt = 0;
  int requestDrawCnt = 0;
  ChineseChessPieceModel capturedPiece = ChineseChessPieceModel(
    type: '',
    isRed: false,
    pos: Point(row: -1, col: -1),
  );

  final isInCheckNotifier = ValueNotifier<bool>(false);
  final isInCheckMateNotifier = ValueNotifier<bool>(false);

  Timer? _gametimer;
  Timer? _moveRequestTimer;
  Timer? _matchTimer;

  @override
  void onInit() {
    super.onInit();
    print('onInit');
    Future.delayed(const Duration(seconds: 1), () {
      isInCheckMateNotifier.value = true;
    });

    playInfo['me']['myTurn'].listen((value) {
      if (stage.value != GameStage.playing) {
        return;
      }
      if (value == true) {
        print('我方回合');
        myStepTime.value = min(
          stepTime.value,
          playInfo['me']['remaining_time'].value,
        );
        startTimer(playInfo['me']['remaining_time'], myStepTime, true);
        getOpponentMove();
      } else {
        print('对方回合');
        requestUndoCnt = 0;
        requestDrawCnt = 0;
        opponentStepTime.value = min(
          stepTime.value,
          playInfo['opponent']['remaining_time'].value,
        );
        startTimer(
          playInfo['opponent']['remaining_time'],
          opponentStepTime,
          false,
        );
        getOpponentMove();

        if (placedPiece.value.type != '') {
          print('发送我方落子');
          sendMyMove(
            placedPiece.value.type,
            sourcePoint.value,
            placedPiece.value.pos,
          );
        }
      }
    });
  }

  @override
  void onClose() {
    stopTimer();
    if (stage.value == GameStage.matching) {
      cancleMatch();
    } else if (stage.value == GameStage.playing) {
      sendMyMove('认输', Point(row: -1, col: -1), Point(row: -1, col: -1));
      overGame('败', 'surrender');
    } else {
      Get.back();
    }
    chatInputController.dispose();
    Get.delete<ChineseChessBoardController>();
    super.onClose();
  }

  // 取消匹配
  void cancleMatch() async {
    print('取消匹配');
    final dio = Dio();
    final response = await dio.post(
      '${GlobalData.url}/CancelMatch',
      data: {'roomId': roomId},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  // 初始化棋盘
  void initChessBoard() {
    initChessPiece();
    print('初始化棋盘');
    chessBoard = List.generate(10, (_) => List.filled(9, null));
    for (var piece in pieces) {
      chessBoard[piece.pos.row][piece.pos.col] = copyPiece(piece);
    }
    sourcePoint.value = Point(row: -1, col: -1);
  }

  // 初始化棋子
  void initChessPiece() {
    print('初始化棋子,${playInfo['me']['isRed']},${playInfo['opponent']['isRed']}');
    pieces.clear();
    pieces.addAll([
      // 上方
      ChineseChessPieceModel(
        type: '車',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 0),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 1),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '相' : '象',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 2),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 3),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '帥' : '將',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 4),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 5),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '相' : '象',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 6),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 7),
      ),
      ChineseChessPieceModel(
        type: '車',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 0, col: 8),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 2, col: 1),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 2, col: 7),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '兵' : '卒',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 3, col: 0),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '兵' : '卒',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 3, col: 2),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '兵' : '卒',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 3, col: 4),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '兵' : '卒',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 3, col: 6),
      ),
      ChineseChessPieceModel(
        type: playInfo['opponent']['isRed'] ? '兵' : '卒',
        isRed: playInfo['opponent']['isRed'],
        pos: Point(row: 3, col: 8),
      ),

      // 下方
      ChineseChessPieceModel(
        type: '車',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 0),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 1),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '相' : '象',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 2),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 3),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '帥' : '將',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 4),
      ),
      ChineseChessPieceModel(
        type: '仕',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 5),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '相' : '象',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 6),
      ),
      ChineseChessPieceModel(
        type: '馬',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 7),
      ),
      ChineseChessPieceModel(
        type: '車',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 9, col: 8),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 7, col: 1),
      ),
      ChineseChessPieceModel(
        type: '炮',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 7, col: 7),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '兵' : '卒',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 6, col: 0),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '兵' : '卒',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 6, col: 2),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '兵' : '卒',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 6, col: 4),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '兵' : '卒',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 6, col: 6),
      ),
      ChineseChessPieceModel(
        type: playInfo['me']['isRed'] ? '兵' : '卒',
        isRed: playInfo['me']['isRed'],
        pos: Point(row: 6, col: 8),
      ),
    ]);
  }

  // 初始化游戏信息
  void initPlayInfo() {
    roomId = '';
    moves.clear();
    myStepTime.value = stepTime.value;
    opponentStepTime.value = stepTime.value;
    playInfo['me']['remaining_time'].value = gameTime.value;
    playInfo['opponent']['remaining_time'].value = gameTime.value;
    playInfo['opponent']['accountId'].value = opponentAccountId;
    print('${playInfo['opponent']['accountId'].value}');

    print(
      '${playInfo['me']['remaining_time'].value},${playInfo['opponent']['remaining_time'].value}',
    );
    print('${myStepTime.value},${opponentStepTime.value}');
  }

  // 菜单栏展开
  void toggleMenu() {
    showMenu.value = !showMenu.value;
    showChat.value = false;
  }

  // 聊天窗口展开
  void toggleChatDialog() {
    showChat.value = !showChat.value;
    showMenu.value = false;
  }

  // 发送消息
  void sendChat(String text) {
    chatInputController.text = text;
    showChat.value = false;
    showMyMessage.value = true;

    Future.delayed(Duration(seconds: 5), () {
      showMyMessage.value = false;
      chatInputController.clear();
    });

    sendMyMove(text, Point(row: -1, col: -1), Point(row: -1, col: -1));
  }

  // 选择棋子
  void selectPiece(ChineseChessPieceModel piece) async {
    if (!(playInfo['me']['myTurn'] == true &&
            piece.isRed == playInfo['me']['isRed'] ||
        playInfo['opponent']['myTurn'] == true &&
            piece.isRed == playInfo['opponent']['isRed'])) {
      return;
    }
    if (piece.isRed != playInfo['me']['isRed']) {
      return;
    }
    selectedPiece.value = piece;
    availableMove.value = canMovePoint(piece, chessBoard);
    print('选中棋子: ${piece.type}, 位置: ${piece.pos.row}, ${piece.pos.col}');
  }

  // 重置选择的棋子
  void resetSelectedPiece() {
    selectedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: false,
      pos: Point(row: -1, col: -1),
    );
  }

  // 清除可移动点的记录
  void clearAvailableMove() {
    availableMove.clear();
  }

  // 移动我方棋子到可移动点
  void moveSelectedPiece(int newRow, int newCol) {
    // 检查新位置是否合法
    bool isContain = false;
    for (var point in availableMove) {
      if (point.row == newRow && point.col == newCol) {
        isContain = true;
        break;
      }
    }
    if (!isContain) {
      return;
    }
    sendKingAlert.value = sendKing(
      selectedPiece.value,
      Point(row: newRow, col: newCol),
    );
    if (sendKingAlert.value) {
      print('送将');
      return;
    }
    // 吃掉对方棋子
    capturePiece(newRow, newCol);
    chessBoard[selectedPiece.value.pos.row][selectedPiece.value.pos.col] = null;
    // 移动棋子
    sourcePoint.value = Point(
      row: selectedPiece.value.pos.row,
      col: selectedPiece.value.pos.col,
    );
    selectedPiece.value.pos.row = newRow;
    selectedPiece.value.pos.col = newCol;
    chessBoard[newRow][newCol] = copyPiece(selectedPiece.value);
    placedPiece.value = selectedPiece.value;

    clearAvailableMove(); // 移动后清除可用移动点
    resetSelectedPiece(); // 移动后重置选中棋子
    turnTransition(); // 切换回合

    // 判断是否处于绝杀状态
    isInCheckMateNotifier.value = checkmate(playInfo['opponent']);
    if (isInCheckMateNotifier.value == true) {
      overGame('胜', 'checkmate');
    }

    // 判断是否将军;
    isInCheckNotifier.value = isInCheckMateNotifier.value
        ? false
        : check(playInfo['opponent'], pieces, chessBoard);

    print('是否我方绝杀: ${isInCheckMateNotifier.value}');
    print('是否我方将军: ${isInCheckNotifier.value}');
  }

  // 移动对方棋子
  void moveOpponentPiece(Point from, Point to) {
    print('moveOpponentPiece');
    if (to.row > 9 || to.row < 0 || to.col > 8 || to.col < 0) {
      return;
    }
    sourcePoint.value = Point(row: from.row, col: from.col);
    capturePiece(to.row, to.col);
    for (var piece in pieces) {
      if (piece.pos.row == from.row && piece.pos.col == from.col) {
        chessBoard[from.row][from.col] = null;
        piece.pos.row = to.row;
        piece.pos.col = to.col;
        placedPiece.value = piece;
        chessBoard[to.row][to.col] = copyPiece(piece);
        break;
      }
    }
    turnTransition(); // 切换回合
    // 判断是否处于绝杀状态
    isInCheckMateNotifier.value = checkmate(playInfo['me']);
    if (isInCheckMateNotifier.value == true) {
      overGame('败', 'checkmate');
    }

    // 判断是否将军;
    isInCheckNotifier.value = isInCheckMateNotifier.value
        ? false
        : check(playInfo['me'], pieces, chessBoard);
    print('是否对方绝杀: ${isInCheckMateNotifier.value}');
    print('是否对方将军: ${isInCheckNotifier.value}');
  }

  // 模拟下一步棋
  void emulatePieces(
    List<ChineseChessPieceModel> prePieces,
    List<List<dynamic>> preChessBoard,
    ChineseChessPieceModel piece,
    Point pos,
  ) {
    for (var p in prePieces) {
      if (p.pos.row == pos.row && p.pos.col == pos.col) {
        prePieces.remove(p);
        break;
      }
    }
    for (var p in prePieces) {
      if (p.type == piece.type &&
          p.isRed == piece.isRed &&
          p.pos.row == piece.pos.row &&
          p.pos.col == piece.pos.col) {
        p.pos.row = pos.row;
        p.pos.col = pos.col;
        break;
      }
    }
    preChessBoard[piece.pos.row][piece.pos.col] = null;
    preChessBoard[pos.row][pos.col] = piece;
  }

  // 计算可移动点
  List<Point> canMovePoint(
    ChineseChessPieceModel piece,
    List<List<dynamic>> preChessBoard,
  ) {
    List<Point> canMove = [];

    switch (piece.type) {
      case '車':
        for (int i = piece.pos.col + 1; i < 9; i++) {
          if (preChessBoard[piece.pos.row][i] == null ||
              preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));
            if (preChessBoard[piece.pos.row][i] != null &&
                preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        for (int i = piece.pos.col - 1; i >= 0; i--) {
          if (preChessBoard[piece.pos.row][i] == null ||
              preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));

            if (preChessBoard[piece.pos.row][i] != null &&
                preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        for (int i = piece.pos.row + 1; i < 10; i++) {
          if (preChessBoard[i][piece.pos.col] == null ||
              preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));

            if (preChessBoard[i][piece.pos.col] != null &&
                preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        for (int i = piece.pos.row - 1; i >= 0; i--) {
          if (preChessBoard[i][piece.pos.col] == null ||
              preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));

            if (preChessBoard[i][piece.pos.col] != null &&
                preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
              break;
            }
          } else {
            break;
          }
        }
        break;
      case '馬':
        List<int> drow = [-1, -2, -2, -1, 1, 2, 2, 1];
        List<int> dcol = [-2, -1, 1, 2, 2, 1, -1, -2];
        List<int> horse_feet_row = [0, -1, -1, 0, 0, 1, 1, 0];
        List<int> horse_feet_col = [-1, 0, 0, 1, 1, 0, 0, -1];
        for (int i = 0; i < 8; i++) {
          int row = piece.pos.row + drow[i];
          int col = piece.pos.col + dcol[i];
          int feet_row = piece.pos.row + horse_feet_row[i];
          int feet_col = piece.pos.col + horse_feet_col[i];
          if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
            if (preChessBoard[row][col] == null ||
                preChessBoard[row][col].isRed != piece.isRed) {
              if (preChessBoard[feet_row][feet_col] == null) {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        }
        break;
      case '相' || '象':
        List<int> drow = [-2, -2, 2, 2];
        List<int> dcol = [-2, 2, -2, 2];
        List<int> elephant_feet_row = [-1, -1, 1, 1];
        List<int> elephant_feet_col = [-1, 1, -1, 1];
        for (int i = 0; i < 4; i++) {
          int row = piece.pos.row + drow[i];
          int col = piece.pos.col + dcol[i];
          int feet_row = piece.pos.row + elephant_feet_row[i];
          int feet_col = piece.pos.col + elephant_feet_col[i];
          if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
            if (piece.pos.row < 5 && row < 5 ||
                piece.pos.row >= 5 && row >= 5) {
              if (preChessBoard[row][col] == null ||
                  preChessBoard[row][col].isRed != piece.isRed) {
                if (feet_row >= 0 &&
                    feet_row <= 9 &&
                    feet_col >= 0 &&
                    feet_col < 9 &&
                    preChessBoard[feet_row][feet_col] == null) {
                  canMove.add(Point(row: row, col: col));
                }
              }
            }
          }
        }
        break;
      case '仕':
        List<int> drow = [-1, -1, 1, 1];
        List<int> dcol = [-1, 1, 1, -1];
        for (int i = 0; i < 4; i++) {
          int row = drow[i] + piece.pos.row;
          int col = dcol[i] + piece.pos.col;
          if (row <= 9 && row >= 7 && col >= 3 && col <= 5 ||
              row >= 0 && row <= 2 && col >= 3 && col <= 5) {
            if (preChessBoard[row][col] == null ||
                preChessBoard[row][col].isRed != piece.isRed) {
              canMove.add(Point(row: row, col: col));
            }
          }
        }
        break;
      case '帥' || '將':
        List<int> drow = [-1, 0, 1, 0];
        List<int> dcol = [0, 1, 0, -1];
        for (int i = 0; i < 4; i++) {
          int row = drow[i] + piece.pos.row;
          int col = dcol[i] + piece.pos.col;
          if ((row >= 7 && row <= 9 || row >= 0 && row <= 2) &&
              col >= 3 &&
              col <= 5) {
            if (preChessBoard[row][col] == null ||
                preChessBoard[row][col].isRed != piece.isRed) {
              canMove.add(Point(row: row, col: col));
            }
          }
        }
        // 两方不能照将
        for (
          int i = piece.pos.row + (piece.pos.row <= 2 ? 1 : -1);
          piece.pos.row <= 2 ? i <= 9 : i >= 0;
          piece.pos.row <= 2 ? i++ : i--
        ) {
          if (preChessBoard[i][piece.pos.col] != null &&
              preChessBoard[i][piece.pos.col].type != '帥' &&
              preChessBoard[i][piece.pos.col].type != '將') {
            break;
          } else if (preChessBoard[i][piece.pos.col] != null &&
              (preChessBoard[i][piece.pos.col].type == '帥' ||
                  preChessBoard[i][piece.pos.col].type == '將')) {
            canMove.add(Point(row: i, col: piece.pos.col));
            break;
          }
        }
        break;
      case '炮':
        for (int i = piece.pos.col + 1, battery = 0; i < 9; i++) {
          if (preChessBoard[piece.pos.row][i] == null) {
            if (battery == 0) {
              canMove.add(Point(row: piece.pos.row, col: i));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1 &&
              preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));
            break;
          }
        }
        for (int i = piece.pos.col - 1, battery = 0; i >= 0; i--) {
          if (preChessBoard[piece.pos.row][i] == null) {
            if (battery == 0) {
              canMove.add(Point(row: piece.pos.row, col: i));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1 &&
              preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));
            break;
          }
        }
        for (int i = piece.pos.row + 1, battery = 0; i < 10; i++) {
          if (preChessBoard[i][piece.pos.col] == null) {
            if (battery == 0) {
              canMove.add(Point(row: i, col: piece.pos.col));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1 &&
              preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));
            break;
          }
        }
        for (int i = piece.pos.row - 1, battery = 0; i >= 0; i--) {
          if (preChessBoard[i][piece.pos.col] == null) {
            if (battery == 0) {
              canMove.add(Point(row: i, col: piece.pos.col));
            }
          } else if (battery == 0) {
            battery++;
          } else if (battery == 1 &&
              preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));
            break;
          }
        }
        break;
      case '兵':
        if (playInfo['me']['isRed'] == true) {
          List<int> drow = [-1, 0, 0];
          List<int> dcol = [0, 1, -1];
          for (int i = 0; i < 3; i++) {
            int row = drow[i] + piece.pos.row;
            int col = dcol[i] + piece.pos.col;
            if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
              if (row == piece.pos.row) {
                if (row <= 4) {
                  canMove.add(Point(row: row, col: col));
                }
              } else {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        }
        break;
      case '卒':
        if (playInfo['me']['isRed'] == false) {
          List<int> drow = [-1, 0, 0];
          List<int> dcol = [0, 1, -1];
          for (int i = 0; i < 3; i++) {
            int row = drow[i] + piece.pos.row;
            int col = dcol[i] + piece.pos.col;
            if (row >= 0 && row <= 9 && col >= 0 && col < 9) {
              if (row == piece.pos.row) {
                if (row <= 4) {
                  canMove.add(Point(row: row, col: col));
                }
              } else {
                canMove.add(Point(row: row, col: col));
              }
            }
          }
        }
        break;
    }
    return canMove;
  }

  // 吃掉棋子
  void capturePiece(int row, int col) {
    pieces.removeWhere((p) => p.pos.row == row && p.pos.col == col);
    if (chessBoard[row][col] != null) {
      capturedPiece = copyPiece(chessBoard[row][col]);
    } else {
      capturedPiece = ChineseChessPieceModel(
        type: '',
        isRed: false,
        pos: Point(row: -1, col: -1),
      );
    }
    chessBoard[row][col] = null;
  }

  // 复制棋子
  ChineseChessPieceModel copyPiece(ChineseChessPieceModel piece) {
    return ChineseChessPieceModel(
      type: piece.type,
      isRed: piece.isRed,
      pos: Point(row: piece.pos.row, col: piece.pos.col),
    );
  }

  //判断是否将军
  bool check(
    Map<String, dynamic> side,
    List<ChineseChessPieceModel> prePieces,
    List<List<dynamic>> preChessBoard,
  ) {
    Point kingPos = Point(row: 0, col: 0);

    // 找到红方或黑方的帥或將
    for (var p in prePieces) {
      if (p.isRed == side['isRed']) {
        if (p.isRed == true) {
          if (p.type == '帥') {
            kingPos = p.pos;
            break;
          }
        } else {
          if (p.type == '將') {
            kingPos = p.pos;
            break;
          }
        }
      }
    }

    return prePieces.any((piece) {
      if (piece.isRed != side['isRed']) {
        return canMovePoint(piece, preChessBoard).any((p) {
          if (p.row == kingPos.row && p.col == kingPos.col) {
            print('${piece.type},${p.row},${p.col}');
            return true;
          }
          return false;
        });
      } else {
        return false;
      }
    });
  }

  //判断是否绝杀
  bool checkmate(Map<String, dynamic> side) {
    for (var p in pieces) {
      if (p.isRed == side['isRed']) {
        List<Point> avalibleMove = canMovePoint(p, chessBoard);
        for (var point in avalibleMove) {
          if (!sendKing(p, point)) {
            print(
              '${p.type},${p.pos.row},${p.pos.col} => ${point.row},${point.col}',
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  //判断是否送将
  bool sendKing(ChineseChessPieceModel piece, Point point) {
    List<ChineseChessPieceModel> prePieces = [];
    List<List<dynamic>> preChessBoard = List.generate(
      10,
      (i) => List.generate(9, (j) => null),
    );
    // 复制一份棋子和棋盘
    for (var p in pieces) {
      prePieces.add(copyPiece(p));
      preChessBoard[p.pos.row][p.pos.col] = copyPiece(p);
    }
    // 模拟将棋子移动到目标位置
    emulatePieces(prePieces, preChessBoard, piece, point);

    return check(
      playInfo['me']['myTurn'].value ? playInfo['me'] : playInfo['opponent'],
      prePieces,
      preChessBoard,
    );
  }

  // 开始匹配
  void startMatching() async {
    stage.value = GameStage.matching;
    initPlayInfo();
    await matching();
    print('matching end');
    initChessBoard();
  }

  // 匹配请求
  Future<void> matching() async {
    final completer = Completer<void>(); // 创建 Completer 来管理 Future 完成状态
    Dio dio = Dio();
    final Map<String, dynamic> params = {
      'player': {
        'accountId': playInfo['me']['accountId'],
        'username': playInfo['me']['username'],
        'avatar': playInfo['me']['avatar'],
        'level': playInfo['me']['level'],
        'isRed': false,
        'timeLeft': gameTime.value,
      },
      'type': '$type${opponentAccountId == '空座' ? '' : ':$opponentAccountId'}',
      'roomId': roomId,
    };

    _matchTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('匹配请求...');
      try {
        final response = await dio.post(
          '${GlobalData.url}/MatchPlayer',
          data: params,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        if (response.data != null && response.data is Map<String, dynamic>) {
          final code = response.data['code'];
          if (code == 0) {
            roomId = response.data['data']['roomId'];
            stage.value = GameStage.playing;
            print(
              '匹配成功,${response.data['data']},${response.data['data']['player1']['isRed'].runtimeType}',
            );

            if (response.data['data']['player1']['accountId'] ==
                playInfo['me']['accountId']) {
              playInfo['opponent']['accountId'].value =
                  response.data['data']['player2']['accountId'];
              playInfo['opponent']['username'].value =
                  response.data['data']['player2']['username'];
              playInfo['opponent']['avatar'].value =
                  response.data['data']['player2']['avatar'];
              playInfo['opponent']['level'].value =
                  response.data['data']['player2']['level'];
              playInfo['opponent']['isRed'] =
                  response.data['data']['player2']['isRed'];
              playInfo['opponent']['myTurn'].value =
                  response.data['data']['player2']['isRed'];
              playInfo['me']['isRed'] =
                  response.data['data']['player1']['isRed'];
              playInfo['me']['myTurn'].value =
                  response.data['data']['player1']['isRed'];
              playInfo['me']['myTurn'].refresh();
              playInfo['opponent']['myTurn'].refresh();
            } else {
              playInfo['opponent']['accountId'].value =
                  response.data['data']['player1']['accountId'];
              playInfo['opponent']['username'].value =
                  response.data['data']['player1']['username'];
              playInfo['opponent']['avatar'].value =
                  response.data['data']['player1']['avatar'];
              playInfo['opponent']['level'].value =
                  response.data['data']['player1']['level'];
              playInfo['opponent']['isRed'] =
                  response.data['data']['player1']['isRed'];
              playInfo['opponent']['myTurn'].value =
                  response.data['data']['player1']['isRed'];
              playInfo['me']['isRed'] =
                  response.data['data']['player2']['isRed'];
              playInfo['me']['myTurn'].value =
                  response.data['data']['player2']['isRed'];
              playInfo['me']['myTurn'].refresh();
              playInfo['opponent']['myTurn'].refresh();
            }

            print('roomId,$roomId,${response.data['data']['roomId']}');
            // 匹配成功，取消定时器
            timer.cancel();
            if (!completer.isCompleted) {
              completer.complete(); // 标记 Future 完成
            }
          } else if (code == 1) {
            roomId = response.data['data']['roomId'];
            params['roomId'] = roomId;
            if (opponentAccountId != '空座' && opponentAccountId != '') {
              print('opponentAccountId: $opponentAccountId');
              await sendInvitation(opponentAccountId);
            }
          }
        }
      } catch (e) {
        print('匹配请求出错: $e');
        if (!completer.isCompleted) {
          completer.completeError(e); // 标记 Future 出错
        }
        timer.cancel();
      }
    });

    return completer.future; // 返回 Completer 管理的 Future
  }

  // 发送我方落子信息
  Future<void> sendMyMove(String type, Point from, Point to) async {
    final Map<String, dynamic> params = {
      'roomId': roomId,
      'step': {
        'accountId': playInfo['me']['accountId'],
        'type': type,
        'from': {'row': from.row, 'col': from.col},
        'to': {'row': to.row, 'col': to.col},
      },
    };
    moves.add(params['step']);
    Dio dio = Dio();
    try {
      final response = await dio.post(
        '${GlobalData.url}/Move',
        data: params,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.data['code'] == 0) {
        print('发送成功,${params['step']['type']}');
      } else {
        print('发送失败,${response.data['msg']}');
      }
    } catch (e) {
      print('发送落子信息出错: $e');
    }
  }

  // 获取对方落子
  Future<void> getOpponentMove() async {
    final List<String> types = [
      '帥',
      '將',
      '仕',
      '相',
      '象',
      '馬',
      '車',
      '炮',
      '兵',
      '卒',
    ];
    final completer = Completer<void>(); // 创建 Completer 来管理 Future 完成状态
    Dio dio = Dio();
    print('调用GetOpponentMove,roomId,${roomId}');
    final Map<String, dynamic> params = {
      'roomId': roomId,
      'moves_length': moves.length,
    };
    _moveRequestTimer = Timer.periodic(
      Duration(seconds: (playInfo['me']['myTurn'].value == true ? 3 : 1)),
      (timer) async {
        print('获取对方落子...');

        try {
          final response = await dio.post(
            '${GlobalData.url}/GetOpponentMove',
            data: params,
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          if (response.data['code'] == 0) {
            final data = response.data['data'];
            print('获取到对方落子: $data');

            // 如果不是对方的操作，则忽略
            if (data['accountId'] != playInfo['opponent']['accountId'].value) {
              print(
                '${data['accountId']}不是${playInfo['opponent']['accountId'].value}',
              );
              return;
            }

            moves.add(data);
            print('moves:${moves.length}');
            params['moves_length'] = moves.length;
            if (data['type'] == '请求悔棋') {
              dealOpponentUndo();
            } else if (data['type'] == '请求和棋') {
              dealOpponentDraw();
            } else if (data['type'] == '认输') {
              dealOpponentSurrender();
            } else if ((data['type'] == '拒绝悔棋' || data['type'] == '拒绝和棋')) {
              Get.back();
              print('Get.back()');
              Get.dialog(
                ShowMessageDialog(content: '对方${data['type']}请求'),
                barrierColor: Colors.transparent,
                barrierDismissible: false,
              );
              Future.delayed(const Duration(milliseconds: 1500), () {
                Get.back();
                print('Get.back()');
              });
            } else if (data['type'] == '同意和棋') {
              Get.back();
              print('Get.back()');
              overGame('和', 'draw');
            } else if (data['type'] == '同意悔棋') {
              Get.back();
              print('Get.back()');
              undo();
            } else if (types.contains(data['type'])) {
              print('movePiece');
              num row = 9 - data['from']['row'].toInt();
              num col = 8 - data['from']['col'].toInt();
              Point from = Point(row: row.toInt(), col: col.toInt());
              moves[moves.length - 1]['from']['row'] = row.toInt();
              moves[moves.length - 1]['from']['col'] = col.toInt();
              row = 9 - data['to']['row'].toInt();
              col = 8 - data['to']['col'].toInt();
              Point to = Point(row: row.toInt(), col: col.toInt());
              moves[moves.length - 1]['to']['row'] = row.toInt();
              moves[moves.length - 1]['to']['col'] = col.toInt();
              moveOpponentPiece(from, to);
              timer.cancel(); // 取消定时器
              if (!completer.isCompleted) {
                completer.complete(); // 标记 Future 完成
              }
            } else {
              //接受text
              receiveText(data['type']);
            }
          }
        } catch (e) {
          print('获取对方落子出错: $e');
          if (!completer.isCompleted) {
            completer.completeError(e); // 标记 Future 出错
          }
          timer.cancel();
        }
      },
    );
    return completer.future; // 返回 Completer 管理的 Future
  }

  // 接受对方信息
  void receiveText(String text) {
    print('receiveText:$text');
    if (text != '') {
      opponentChatMessage.value = text;
      playInfo['opponent']['showMessage'].value = true;
      Future.delayed(const Duration(milliseconds: 5000), () {
        playInfo['opponent']['showMessage'].value = false;
      });
    }
  }

  // 后端推送邀请通知给好友
  Future<void> sendInvitation(String accountId) async {
    final Map<String, dynamic> params = {
      'accountId': GlobalData.userInfo['accountId'],
      'invitation': {
        'accountId': accountId,
        'roomId': roomId,
        'type': type,
        'gameTime': gameTime.value,
        'stepTime': stepTime.value,
      },
    };
    Dio dio = new Dio();
    try {
      final response = await dio.post(
        '${GlobalData.url}/SendInvitation',
        data: params,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.data['code'] == 0) {
        print('发送邀请成功');
        Get.dialog(
          ShowMessageDialog(content: '发送邀请成功'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      print('发送邀请失败:$e');
    }
  }

  // 悔棋操作
  void undo() {
    print('悔棋操作');
    List<String> piece = [
      '車',
      '馬',
      '相',
      '象',
      '仕',
      '帥',
      '將',
      '将',
      '炮',
      '兵',
      '卒',
    ];
    for (var move in moves.reversed) {
      if (piece.contains(move['type'])) {
        Point from = Point(row: move['to']['row'], col: move['to']['col']);
        Point to = Point(row: move['from']['row'], col: move['from']['col']);
        placedPiece.value.pos.row = to.row;
        placedPiece.value.pos.col = to.col;
        chessBoard[to.row][to.col] = copyPiece(placedPiece.value);
        if (capturedPiece.type != '') {
          pieces.add(copyPiece(capturedPiece));
          chessBoard[from.row][from.col] = copyPiece(capturedPiece);
        } else {
          chessBoard[from.row][from.col] = null;
        }
        selectedPiece.value = ChineseChessPieceModel(
          type: '',
          isRed: false,
          pos: Point(row: -1, col: -1),
        );
        placedPiece.value = ChineseChessPieceModel(
          type: '',
          isRed: false,
          pos: Point(row: -1, col: -1),
        );
        sourcePoint.value = Point(row: -1, col: -1);
        break;
      }
    }
    turnTransition();
    moves.clear();
  }

  // 请求悔棋
  void requestUndo() async {
    if (playInfo['opponent']['myTurn'].value == true) {
      if (requestUndoCnt == 0) {
        Get.dialog(
          LoadingDialog(content: '请求对方悔棋中'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        requestUndoCnt++;
        await sendMyMove(
          '请求悔棋',
          Point(row: -1, col: -1),
          Point(row: -1, col: -1),
        );
      } else {
        Get.dialog(
          ShowMessageDialog(content: '每个回合只能请求一次'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
          print('Get.back()');
        });
      }
    } else {
      Get.dialog(
        ShowMessageDialog(content: '我方回合不可悔棋'),
        barrierColor: Colors.transparent,
        barrierDismissible: false,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
        print('Get.back()');
      });
    }
  }

  // 请求和棋
  void requestDraw() async {
    if (playInfo['opponent']['myTurn'].value == true) {
      if (requestDrawCnt == 0) {
        Get.dialog(
          LoadingDialog(content: '请求对方和棋中'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        requestDrawCnt++;
        await sendMyMove(
          '请求和棋',
          Point(row: -1, col: -1),
          Point(row: -1, col: -1),
        );
      } else {
        Get.dialog(
          ShowMessageDialog(content: '每个回合只能请求一次'),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
          print('Get.back()');
        });
      }
    } else {
      Get.dialog(
        ShowMessageDialog(content: '我方回合不可和棋'),
        barrierColor: Colors.transparent,
        barrierDismissible: false,
      );
      Future.delayed(Duration(milliseconds: 1500), () {
        Get.back();
        print('Get.back()');
      });
    }
  }

  // 认输
  void surrender() {
    Get.dialog(
      ConfirmDialog(
        content: '确定认输吗',
        confirmText: '确定',
        cancelText: '取消',
        onConfirm: () {
          Get.back();
          print('Get.back()');
          sendMyMove('认输', Point(row: -1, col: -1), Point(row: -1, col: -1));
          overGame('败', 'surrender');
        },
        onCancel: () {
          Get.back();
          print('Get.back()');
        },
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  // 处理对方悔棋请求
  void dealOpponentUndo() {
    print('对方请求悔棋');
    Get.dialog(
      ConfirmDialog(
        content: '对方请求悔棋',
        confirmText: '同意',
        cancelText: '拒绝',
        onConfirm: () {
          Get.back();
          print('Get.back()');
          acceptOpponentUndo();
        },
        onCancel: () {
          Get.back();
          print('Get.back()');
          rejectOpponentUndo();
        },
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  // 接受对方悔棋
  void acceptOpponentUndo() async {
    await sendMyMove('同意悔棋', Point(row: -1, col: -1), Point(row: -1, col: -1));
    undo();
  }

  // 拒绝对方悔棋
  void rejectOpponentUndo() {
    sendMyMove('拒绝悔棋', Point(row: -1, col: -1), Point(row: -1, col: -1));
  }

  // 处理对方和棋请求
  void dealOpponentDraw() {
    print("对方请求和棋");
    Get.dialog(
      ConfirmDialog(
        content: '对方请求和棋',
        confirmText: '同意',
        cancelText: '拒绝',
        onConfirm: () {
          Get.back();
          acceptOpponentDraw();
        },
        onCancel: () {
          Get.back();
          print('Get.back()');
          rejectOpponentDraw();
        },
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  // 接受对方和棋请求
  void acceptOpponentDraw() async {
    await sendMyMove('同意和棋', Point(row: -1, col: -1), Point(row: -1, col: -1));
    overGame('和', 'draw');
  }

  // 拒绝对方和棋请求
  void rejectOpponentDraw() {
    sendMyMove('拒绝和棋', Point(row: -1, col: -1), Point(row: -1, col: -1));
  }

  // 处理对方认输
  void dealOpponentSurrender() {
    Get.dialog(ShowMessageDialog(content: '对方认输'));
    Future.delayed(const Duration(milliseconds: 1000), () {
      Get.back();
      print('Get.back()');
    });
    overGame('胜', 'surrender');
  }

  // 游戏结束
  void overGame(String res, String reason) async {
    Dio dio = Dio();
    final Map<String, dynamic> params = {
      'roomId': roomId,
      'type': type,
      'result': {
        'winner': res == '胜'
            ? playInfo['me']['accountId']
            : res == '败'
            ? playInfo['opponent']['accountId'].value
            : '和',
        'reason': reason,
      },
    };
    try {
      final response = await dio.post(
        '${GlobalData.url}/WritingResult',
        data: params,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print(response.data['msg']);
    } catch (e) {
      print('写入结果出错: $e');
    }
    GlobalData.userInfo['activity'] += 10;
    GlobalData.userInfo['ChineseChess']['levelBar'] += res == '胜'
        ? 10
        : res == '败'
        ? -10
        : 0;
    if (GlobalData.userInfo['ChineseChess']['levelBar'] > 100) {
      GlobalData.userInfo['ChineseChess']['levelBar'] %= 100;
      final level = GlobalData.userInfo['ChineseChess']['level'].split('-');
      level[1] = level[1] - '0' + 1;
      if (level[1] - '0' > 3) {
        level[1] = 1;
        level[0] = level[0] - '0' + 1;
      }
      GlobalData.userInfo['ChineseChess']['level'] = level.join('-');
    }

    stage.value = GameStage.over;
    result = res;
    selectedPiece.value = ChineseChessPieceModel(
      type: '',
      isRed: false,
      pos: Point(row: -1, col: -1),
    );
    placedPiece.value = copyPiece(selectedPiece.value);
    stopTimer();
    print('res,$res');
  }

  // 回合转换
  void turnTransition() {
    playInfo['me']['myTurn'].value = !playInfo['me']['myTurn'].value;
    playInfo['opponent']['myTurn'].value =
        !playInfo['opponent']['myTurn'].value;

    myStepTime.value = stepTime.value;
    opponentStepTime.value = stepTime.value;
  }

  // 开始计局时和步时
  void startTimer(RxInt time, RxInt stepTime, bool myTurn) async {
    stopTimer();
    _gametimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time > 0 && stepTime.value > 0) {
        time.value--;
        stepTime.value--;
      } else {
        stopTimer();
        if (myTurn == true) {
          Get.dialog(
            ShowMessageDialog(content: '我方超时'),
            barrierColor: Colors.transparent,
            barrierDismissible: false,
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
            print('Get.back()');
            overGame('败', 'timeOut');
          });
        } else {
          Get.dialog(
            ShowMessageDialog(content: '对方超时'),
            barrierColor: Colors.transparent,
            barrierDismissible: false,
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
            print('Get.back()');
            overGame('胜', 'timeOut');
          });
        }
        print('时间耗尽，游戏结束');
      }
    });
  }

  // 停止所有计数器
  void stopTimer() {
    _gametimer?.cancel();
    _gametimer = null;
    _moveRequestTimer?.cancel();
    _moveRequestTimer = null;
    _matchTimer?.cancel();
    _matchTimer = null;
  }
}

enum GameStage { idle, matching, playing, over }
