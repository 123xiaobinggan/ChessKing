
module.exports = (io, socket, roomCollection, accountIdMap) => {
    socket.on('sendMessages', async (message) => {
        console.log('sendMessages', message);
        const socketRoomId = socket.data.socketRoomId
        console.log('socketRoomId',socketRoomId)
        io.to(socketRoomId).emit('receiveMessages', message);
    })
}