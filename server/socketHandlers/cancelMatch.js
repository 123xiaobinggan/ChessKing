
module.exports = (io, socket, waitingPlayers) => {
    io.on('cancelMatch', async () => {
        console.log('cancelMatch',socket.id);
        for (var i = 0; i < waitingPlayers.length; i++) {
            var player = waitingPlayers[i]
            if (player.id == socket.id) {
                waitingPlayers.splice(i, 1);
                break;
            }
        }
    })
}