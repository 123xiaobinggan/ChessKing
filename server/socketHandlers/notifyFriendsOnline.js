
module.exports = (io, socket, accountIdMap) => {
    socket.on('notifyFriendsOnline', async (params) => {
        const accountId = params['accountId'];
        const friends = params['friends']
        socketFriends = [];
        for (var friend of friends) {
            if (accountIdMap[friend]) {
                socketFriends.push(accountIdMap[friend]);
            }
        }
        for (var soc of socketFriends) {
            console.log('soc.data.accountId',soc.data.accountId)
            soc.emit('receiveFriendsOnline', { accountId });
        }

    })
}