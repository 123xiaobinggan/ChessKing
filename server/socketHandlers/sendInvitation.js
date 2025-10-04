

module.exports = (io, socket, userCollection,accountIdMap) => {
    socket.on('sendInvitation', async (data) => {

        const inviteeAccountId = data['inviteeAccountId'];
        const inviterAccountId = data['inviterAccountId'];
        const inviterSocket = accountIdMap[inviterAccountId]
        const inviterUser = await userCollection.findOne({
            accountId: inviterAccountId
        });
        
        const socketRoomId = data['socketRoomId'];
        inviterSocket.join(socketRoomId);
        inviterSocket.data.socketRoomId = socketRoomId;
        inviterSocket.data.accountId = inviterAccountId;
        console.log('sendInvitation', data)
        if (accountIdMap[inviteeAccountId]) {
            data['avatar'] = inviterUser.avatar;
            data['username'] = inviterUser.username;
            console.log('data', data);
            io.to(accountIdMap[inviteeAccountId].id).emit('receiveInvitation', data);
        }
    })
}

