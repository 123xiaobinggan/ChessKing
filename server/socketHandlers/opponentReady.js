
module.exports = (io, socket, accountIdMap) => {
    socket.on('ready', (opponentAccountId) => {
        console.log('ready', opponentAccountId);
        if (accountIdMap[opponentAccountId]) {
            console.log('accountIdMap', accountIdMap, accountIdMap[opponentAccountId])
            io.to(accountIdMap[opponentAccountId]).emit('opponentReady');
        }
    })
}