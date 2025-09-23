
module.exports = (io,socket,accountIdMap) =>{
    socket.on('sendOpponentInformation',(data)=>{
        console.log('sendOpponentInformation',data);
        const inviteeAccountId = data['inviteeAccountId'];
        if(accountIdMap[inviteeAccountId]){
            io.to(accountIdMap[inviteeAccountId]).emit('opponentSendInformation');
        }
    })
}