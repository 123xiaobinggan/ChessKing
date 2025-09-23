
module.exports = (io, socket, accountIdMap) => {
    socket.on('dealInvitation', async (data) => {
        console.log('dealInvitation',data);
        const inviterAccountId = data['inviterAccountId'];
        if (accountIdMap[inviterAccountId]) {
            console.log('data',data);
            io.to(accountIdMap[inviterAccountId]).emit('opponentDealInvitation', data);
        }
    })
}