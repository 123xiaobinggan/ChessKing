
module.exports = (io, socket, waitingPlayers, userCollection, roomCollection, accountIdMap) => {
  socket.on('ChineseChessWithFriends', async (params) => {
    const player = params['player'];
    const opponentAccountId = params['opponentAccountId'];
    const type = params['type']

    let opponent = waitingPlayers.filter(
      play => play['accountId'] == opponentAccountId && play['type'] == type
    )[0];
    try {
      if (opponent) {
        let player1, player2;
        if (socket.data.socketRoomId) {
          const socketRoomId = socket.data.socketRoomId.split('-');
          const inviterAccountId = socketRoomId[0];
          const projection = { accountId: 1, username: 1, avatar: 1 };
          projection[`${transform(type)}.level`] = 1;
          if (inviterAccountId == player['accountId']) {
            player1 = player;
            player2 = await userCollection.findOne(
              { accountId: opponentAccountId },
              { projection }
            );
            player2 = {
              accountId: player2.accountId,
              username: player2.username,
              avatar: player2.avatar,
              level: player2[transform(type)]['level'],
              timeLeft: player.timeLeft
            }

          } else {
            player2 = player;
            player1 = await userCollection.findOne(
              { accountId: opponentAccountId },
              { projection }
            );
            player1 = {
              accountId: player1.accountId,
              username: player1.username,
              avatar: player1.avatar,
              level: player1[transform(type)]['level'],
              timeLeft: player.timeLeft
            }
          }
          player1.isRed = Math.random() > 0.5
          player2.isRed = !player1.isRed
          const newRoom = {
            player1,
            player2,
            type,
            timeMode: player.timeLeft,
            status: 'playing',
            moves: [],
            actions: [],
            messages: [],
            result: {
              winner: null,
              result: null
            },
            createdAt: new Date(),
            board: initialBoard()
          }
          const res = await roomCollection.insertOne(newRoom);
          const roomId = res.insertedId.toString();
          io.to(socket.data.socketRoomId).emit('match_success', {
            player1,
            player2,
            roomId,
            socketRoomId: socket.data.socketRoomId
          });
          console.log('roomId',roomId);
          socket.data.roomId = roomId;
          accountIdMap[opponentAccountId].data.roomId = roomId;

          // 移除已经匹配的对手
          for (var i = 0; i < waitingPlayers.length; i++) {
            var p = waitingPlayers[i];
            if (p['accountId'] == opponent['accountId']) {
              waitingPlayers.splice(i, 1);
              break;
            }
          }
        }
      } else {
        waitingPlayers.push({ id: socket.id, socket, ...player, type });
        console.log('waitingPlayers', waitingPlayers.map((waitingPlayer => waitingPlayer.accountId)));
        io.to(accountIdMap[opponentAccountId].id).emit('opponentReady');
      }
    } catch (e) {
      console.log('e', e);
    }
  });
};

function transform(type) {
  if (type.includes('ChineseChess')) {
    return 'ChineseChess';
  } else if (type.includes('Go')) {
    return 'Go'
  } else if (type.includes('Military')) {
    return 'Military'
  } else {
    return 'Fir'
  }
}

function initialBoard() {
  return [
    {
      type: '車',
      isRed: false,
      pos: { row: 0, col: 0 },
    },
    {
      type: '馬',
      isRed: false,
      pos: { row: 0, col: 1 },
    },
    {
      type: '象',
      isRed: false,
      pos: { row: 0, col: 2 },
    },
    {
      type: '仕',
      isRed: false,
      pos: { row: 0, col: 3 },
    },
    {
      type: '將',
      isRed: false,
      pos: { row: 0, col: 4 },
    },
    {
      type: '仕',
      isRed: false,
      pos: { row: 0, col: 5 },
    },
    {
      type: '象',
      isRed: false,
      pos: { row: 0, col: 6 },
    },
    {
      type: '馬',
      isRed: false,
      pos: { row: 0, col: 7 },
    },
    {
      type: '車',
      isRed: false,
      pos: { row: 0, col: 8 },
    },
    {
      type: '炮',
      isRed: false,
      pos: { row: 2, col: 1 },
    },
    {
      type: '炮',
      isRed: false,
      pos: { row: 2, col: 7 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 0 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 2 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 4 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 6 },
    },
    {
      type: '卒',
      isRed: false,
      pos: { row: 3, col: 8 },
    },

    // 下方
    {
      type: '車',
      isRed: true,
      pos: { row: 9, col: 0 },
    },
    {
      type: '馬',
      isRed: true,
      pos: { row: 9, col: 1 },
    },
    {
      type: '相',
      isRed: true,
      pos: { row: 9, col: 2 },
    },
    {
      type: '仕',
      isRed: true,
      pos: { row: 9, col: 3 },
    },
    {
      type: '帥',
      isRed: true,
      pos: { row: 9, col: 4 },
    },
    {
      type: '仕',
      isRed: true,
      pos: { row: 9, col: 5 },
    },
    {
      type: '相',
      isRed: true,
      pos: { row: 9, col: 6 },
    },
    {
      type: '馬',
      isRed: true,
      pos: { row: 9, col: 7 },
    },
    {
      type: '車',
      isRed: true,
      pos: { row: 9, col: 8 },
    },
    {
      type: '炮',
      isRed: true,
      pos: { row: 7, col: 1 },
    },
    {
      type: '炮',
      isRed: true,
      pos: { row: 7, col: 7 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 0 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 2 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 4 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 6 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 8 },
    },

  ];
}