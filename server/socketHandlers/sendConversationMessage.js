const { ObjectId } = require('bson');
module.exports = (io, socket, messageCollection, conversationCollection, accountIdMap) => {
    socket.on('sendConversationMessage', async (message) => {
        message.createdAt = new Date(message.createdAt)
        console.log('message', message);
        const opponentSocket = accountIdMap[message['receiverAccountId']];
        console.log('opponentSocket', opponentSocket?.id);
        socket.emit('receiveConversationMessage', message);
        if (opponentSocket) {
            opponentSocket.emit('receiveConversationMessage', message);
        }

        try {
            await messageCollection.insertOne({
                ...message
            });

            await conversationCollection.updateOne(
                { _id: new ObjectId(message['conversationId']) },
                {
                    $inc: { [`unreadCnt.${message['receiverAccountId']}`]: 1 },
                    $set: { lastTime: new Date(), lastMessage: message.content }
                }
            )

        } catch (e) {
            console.log('e', e);
        }

    })
}