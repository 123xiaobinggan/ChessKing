const { ObjectId } = require('bson');
module.exports = (io, socket, roomCollection, accountIdMap) => {
    socket.on('sendMessages', async (message) => {
        console.log('sendMessages', message);
        const room = await roomCollection.findOne({
            _id: new ObjectId(message.roomId)
        });
        if (room) {
            const res = await roomCollection.updateOne(
                { _id: new ObjectId(message.roomId) },
                { $push: { messages: message } }
            )
            console.log('res', res);
        }
        io.to(message.roomId).emit('receiveMessages', message);
    })
}