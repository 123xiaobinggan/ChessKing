
module.exports = (io, socket, db, waitingPlayers, roomCollection) => {
  socket.on('ChineseChessMatch', async (params) => {
    const player = params['player'];
    const inviter = params['inviter'];
    console.log('请求匹配', player['accountId']);
    console.log('inviter',inviter);
    console.log('waitingPlayers',waitingPlayers.map(player=>player.accountId));
    const opponents = waitingPlayers.filter(
      play => play['accountId']!=player['accountId'] && play['type'] === player['type'] && play['timeMode'] === player['timeMode'] && ((inviter != '' && play['accountId'] == inviter) || inviter == '')
    );
    console.log('opponents',opponents);
    
    if (opponents.length > 0) {
      const opponent = opponents[0];
      player.id = socket.id;
      const player1 = { ...player, isRed: Math.random() > 0.5 };
      const player2 = { ...opponent, isRed: !player1.isRed };
      delete player2.socket; // 避免把 socket 对象插入数据库

      const newRoom = {
        player1,
        player2,
        type: 'ChineseChessMatch',
        timeMode: player['timeMode'],
        status: 'playing',
        moves: [],
        result: { winner: null, reason: null },
        createdAt: Date.now(),
        board: initialBoard()
      };

      const res = await roomCollection.insertOne(newRoom);
      const roomId = res.insertedId.toString();

      // 加入 socket.io 房间
      socket.join(roomId);
      opponent.socket.join(roomId);
      socket.accountId = player['accountId'];
      socket.roomId = roomId;
      opponent.socket.accountId = player2['accountId'];
      opponent.socket.roomId = roomId;

      io.to(roomId).emit("match_success", {
        roomId,
        player1,
        player2,
      });

      // 移除已经匹配的对手
      for(var i = 0;i<waitingPlayers.length;i++){
        var p = waitingPlayers[i];
        if(p['accountId']==opponent['accountId']){
          waitingPlayers.splice(i,1);
          break;
        }
      }
    } else {
      waitingPlayers.push({ id: socket.id, socket, ...player });
      console.log('waitingPlayers',waitingPlayers.map((waitingPlayer => waitingPlayer.accountId)));
      socket.emit("waiting", { msg: "匹配中", waitingId:socket.id });
    }
  });
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
      type: '帥' ,
      isRed: true,
      pos: { row: 9, col: 4 },
    },
    {
      type: '仕',
      isRed: true,
      pos: { row: 9, col: 5 },
    },
    {
      type: '相' ,
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
      type: '兵' ,
      isRed: true,
      pos: { row: 6, col: 0 },
    },
    {
      type: '兵' ,
      isRed: true,
      pos: { row: 6, col: 2 },
    },
    {
      type: '兵' ,
      isRed: true,
      pos: { row: 6, col: 4 },
    },
    {
      type: '兵',
      isRed: true,
      pos: { row: 6, col: 6 },
    },
    {
      type: '兵' ,
      isRed: true,
      pos: { row: 6, col: 8 },
    },

  ];
}