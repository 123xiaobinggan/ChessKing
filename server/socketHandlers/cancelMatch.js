const { ObjectId } = require('bson');

module.exports = (io, socket, roomCollection, waitingPlayers) => {
    socket.on('cancelMatch', async () => {
        console.log('cancelMatch', socket.id,socket.roomId);
        for (var i = 0; i < waitingPlayers.length; i++) {
            var player = waitingPlayers[i]
            if (player.id == socket.id) {
                waitingPlayers.splice(i, 1);
                break;
            }
        }
        if (socket.roomId) {
            await roomCollection.deleteOne({
                _id: new ObjectId(socket.roomId)
            })
        }
        io.to(socket.roomId).emit('opponentLeave');
    })
}