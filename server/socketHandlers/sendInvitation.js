

module.exports = (io, socket, userCollection, accountIdMap) => {
    socket.on('sendInvitation', async (data) => {
        
        const inviteeAccountId = data['inviteeAccountId'];
        console.log('sendInvitation',data,accountIdMap,accountIdMap[`${inviteeAccountId}`])
        if (accountIdMap[inviteeAccountId]) {
            const res = await userCollection.findOne({
                accountId: data['inviterAccountId']
            });
            if(res){
                data['avatar'] = res.avatar;
                data['username'] = res.username;
            }
            console.log('data',data);
            io.to(accountIdMap[inviteeAccountId]).emit('receiveInvitation', data);
        }
    })
}