
module.exports = (io, socket, db, waitingPlayers) => {
  socket.on('disconnect', () => {
    console.log('断开连接', socket.id);
    for (var i = 0; i < waitingPlayers.length; i++) {
      var player = waitingPlayers[i]
      if (player.id == socket.id) {
        waitingPlayers.splice(i, 1);
        break;
      }
    }
    console.log('断开连接 waitingPlayers', waitingPlayers.map(player => player.accountId));
  });
}