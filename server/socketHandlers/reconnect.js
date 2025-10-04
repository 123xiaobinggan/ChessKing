const { ObjectId } = require('bson');
//断线重连
module.exports = (io, socket,accountIdMap, roomCollection) => {
  socket.on('reconnectRoom', async (data) => {
    
    const accountId = data.accountId;
    const roomId = data.roomId;
    const socketRoomId = data.socketRoomId;
    console.log('data', data);
    console.log(`玩家 ${accountId} 尝试重连房间 ${roomId}`);
    if(socketRoomId){
      socket.join(socketRoomId);
    }

    try {
      const room = await roomCollection.findOne({ _id: new ObjectId(roomId) });
      if (!room) {
        socket.emit("reconnect_failed", { msg: "房间不存在" });
        return;
      }

      // 检查玩家是否在这个房间
      const isPlayerInRoom =
        room.player1.accountId === accountId ||
        room.player2.accountId === accountId;

      if (!isPlayerInRoom) {
        socket.emit("reconnect_failed", { msg: "你不是该房间的玩家" });
        return;
      }

      socket.data.accountId = accountId;
      socket.data.socketRoomId = socketRoomId
      socket.data.roomId = roomId
      accountIdMap[accountId] = socket;

      let opponentSocket = '';

      // 更新玩家 socketId(方便继续通信)
      if (room.player1.accountId === accountId) {
        opponentSocket = accountIdMap[room.player2.accountId];
      } else {
        opponentSocket = accountIdMap[room.player1.accountId];
      }

      // 把当前棋局状态发给玩家
      socket.emit("reconnect_success", {
        roomId,
        player1: room.player1,
        player2: room.player2,
        moves: room.moves,
        status: room.status,
        result: room.result,
      });

      if (opponentSocket) {
        opponentSocket.emit('opponentReconnect');
      }

      console.log(`玩家 ${accountId} 重连成功，进入房间 ${roomId}`);

    } catch (err) {
      console.error("重连错误:", err);
      socket.emit("reconnect_failed", { msg: "服务器错误" });
    }
  });
}