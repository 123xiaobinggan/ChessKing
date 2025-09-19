// 棋子模型
class ChineseChessPieceModel {
  String type; // 如：'车'、'马'、'兵'、'帅'
  bool isRed; // 是否为红方
  Point pos;

  ChineseChessPieceModel({
    required this.type,
    required this.isRed,
    required this.pos,
  });
}

// 棋盘坐标
class Point {
  int row;
  int col;
  Point({required this.row, required this.col});
}

// 游戏信息
Map<String, dynamic> playInfo = {
  "me": {
    "accountId": 'GlobalData.userInfo=',
    'username': 'GlobalData.userInfo=',
    'avatar': 'GlobalData.userInfo=',
    'level': 'GlobalData.userInfo',
    'timeLeft': 0,
    'myTurn': true,
    'showMessage': false,
    'isRed': false, // 红方
  },
  "opponent": {
    "accountId": '空座',
    'username': '空座',
    'avatar':
        'https://binggan-1358387153.cos.ap-guangzhou.myqcloud.com/User/NotLogin.png',
    'level': '1-1',
    'timeLeft': 0,
    'showMessage': 0,
    'myTurn': false,
    'isRed': true, // 黑方
  },
};

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
          if (piece.pos.row < 5 && row < 5 || piece.pos.row >= 5 && row >= 5) {
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
        } else if (battery == 1) {
          if (preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));
          }
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
        } else if (battery == 1) {
          if (preChessBoard[piece.pos.row][i].isRed != piece.isRed) {
            canMove.add(Point(row: piece.pos.row, col: i));
          }
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
        } else if (battery == 1) {
          if (preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));
          }
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
        } else if (battery == 1) {
          if (preChessBoard[i][piece.pos.col].isRed != piece.isRed) {
            canMove.add(Point(row: i, col: piece.pos.col));
          }
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

// 检查是否被将军
bool check(
  Map<String, dynamic> side,
  List<ChineseChessPieceModel> prePieces,
  List<List<dynamic>> preChessBoard,
) {
  Point kingPos = Point(row: 0, col: 0);

  // 找到红方或黑方的帥或將
  for (var p in prePieces) {
    // print('${p.type},${p.isRed},${p.pos.row},${p.pos.col}');
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

  print('KingPos,${kingPos.row},${kingPos.col}');

  return prePieces.any((piece) {
    if (piece.isRed != side['isRed']) {
      return canMovePoint(piece, preChessBoard).any((p) {
        if (p.row == kingPos.row && p.col == kingPos.col) {
          print(
            'eatKing:${piece.type},${piece.isRed},${piece.pos.row},${piece.pos.col} to ${p.row},${p.col}',
          );
          print('KingPos,${kingPos.row},${kingPos.col}');
          return true;
        }
        return false;
      });
    } else {
      return false;
    }
  });
}

void main() {
  // print("hello world");
  List<ChineseChessPieceModel> prePieces = [];
  List<List<dynamic>> preChessBoard = List.generate(
    10,
    (i) => List.generate(9, (j) => null),
  );
  init(prePieces, preChessBoard);
  for (int i = 0; i < preChessBoard.length; i++) {
        String row = '';
        for (int j = 0; j < preChessBoard[i].length; j++) {
          final piece = preChessBoard[i][j];
          row += (piece != null ? '${piece.type} ' : '· ') + '  '; // 用·表示空位
        }
        print(row);
      }
  // print(prePieces[0]);
  bool isCheck = check(playInfo['me'], prePieces, preChessBoard);
  print(isCheck);
}

void init(
  List<ChineseChessPieceModel> prePieces,
  List<List<dynamic>> preChessBoard,
) {
  prePieces.addAll([
    ChineseChessPieceModel(type: '相', isRed: true, pos: Point(row: 0, col: 2)),
    ChineseChessPieceModel(type: '帥', isRed: true, pos: Point(row: 0, col: 4)),
    ChineseChessPieceModel(type: '炮', isRed: true, pos: Point(row: 1, col: 3)),
    ChineseChessPieceModel(type: '仕', isRed: true, pos: Point(row: 2, col: 3)),
    ChineseChessPieceModel(type: '相', isRed: true, pos: Point(row: 2, col: 4)),
    ChineseChessPieceModel(type: '仕', isRed: true, pos: Point(row: 2, col: 5)),
    ChineseChessPieceModel(type: '兵', isRed: true, pos: Point(row: 3, col: 0)),
    ChineseChessPieceModel(type: '兵', isRed: true, pos: Point(row: 4, col: 6)),
    ChineseChessPieceModel(type: '兵', isRed: true, pos: Point(row: 3, col: 8)),
    ChineseChessPieceModel(type: '炮', isRed: true, pos: Point(row: 6, col: 0)),
    //
    ChineseChessPieceModel(type: '卒', isRed: false, pos: Point(row: 5, col: 2)),
    ChineseChessPieceModel(type: '卒', isRed: false, pos: Point(row: 5, col: 8)),
    ChineseChessPieceModel(type: '將', isRed: false, pos: Point(row: 7, col: 3)),
    ChineseChessPieceModel(type: '象', isRed: false, pos: Point(row: 5, col: 6)),
    ChineseChessPieceModel(type: '仕', isRed: false, pos: Point(row: 8, col: 4)),
    ChineseChessPieceModel(type: '仕', isRed: false, pos: Point(row: 9, col: 5)),
    ChineseChessPieceModel(type: '象', isRed: false, pos: Point(row: 9, col: 6)),
  ]);

  for (var p in prePieces) {
    preChessBoard[p.pos.row][p.pos.col] = copyPiece(p);
  }
}

// 复制棋子
ChineseChessPieceModel copyPiece(ChineseChessPieceModel piece) {
  return ChineseChessPieceModel(
    type: piece.type,
    isRed: piece.isRed,
    pos: Point(row: piece.pos.row, col: piece.pos.col),
  );
}
