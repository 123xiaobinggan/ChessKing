const { ObjectId } = require('bson');
module.exports = (io, socket, db, waitingPlayers, accountIdMap, roomCollection) => {
  socket.on('disconnect', async () => {
    console.log('断开连接', socket.id,socket.accountId,socket.roomId);

    for (var i = 0; i < waitingPlayers.length; i++) {
      var player = waitingPlayers[i]
      if (player.id == socket.id) {
        waitingPlayers.splice(i, 1);
        break;
      }
    }

    if (socket.roomId) {
      const room = await roomCollection.findOne({ _id: new ObjectId(socket.roomId) });
      console.log('socket.accountId', socket.accountId, socket.roomId);
      if (room) {
        if (room.player1.accountId == socket.accountId) {
          console.log('player2', room.player2,room.player2.accountId, typeof room.player2.accountId);
          console.log('player2.id',room.player2.id)
          io.to(room.player2.id).emit('opponentDisconnect');
        }
        else {
          console.log('player1.id', room.player1.id);
          console.log('player1', room.player1,room.player1.accountId);
          io.to(room.player1.id).emit('opponentDisconnect');
        }
      }
    } else {
      console.log('socket.roomId为空')
    }
    delete accountIdMap[socket.accountId];
  });
}