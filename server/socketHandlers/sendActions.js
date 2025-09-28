const { ObjectId } = require('bson');

module.exports = (io, socket, roomCollection, accountIdMap) => {
    socket.on('sendActions', async (action) => {
        console.log('sendActions', action);
        const room = await roomCollection.findOne({
            _id: new ObjectId(action.roomId)
        })
        if (room) {
            const res = await roomCollection.updateOne(
                { _id: new ObjectId(room.id) },
                { $push: { actions: action } }
            )
            console.log('res', res);
            if (room.type.includes('Ai')) {
                if (action.type == '请求悔棋') {
                    io.to(action.roomId).emit('receiveActions', {
                        roomId: action.roomId,
                        accountId: room.player2.accountId,
                        type: "同意悔棋"
                    });
                    undo(room, action.accountId);
                    await roomCollection.updateOne(
                        { _id: new ObjectId(action.roomId) },
                        {
                            $set: { board: room.board }
                        },
                    );
                } else if(action.type == "请求和棋"){
                    io.to(action.roomId).emit('receiveActions',{
                        roomId: action.roomId,
                        accountId: room.player2.accountId,
                        type: "请求和棋"
                    });
                }
                return ;
            }
        }
        io.to(action.roomId).emit('receiveActions', action);
    })
}

function undo(room, accountId) {
  for (var i = room.moves.length - 1; i >= 0; i--) {
    var moved = room.moves[i];
    if (accountId == moved.accountId) {
      var from_row = moved.to.row;
      var from_col = moved.to.col;
      var to_row = moved.from.row;
      var to_col = moved.from.col;
      for (var j = 0; j < room.board.length; j++) {
        var piece = room.board[j];
        if (piece.type == moved.type && piece.pos.row == from_row && piece.pos.col == from_col) {
          piece.pos.row = to_row;
          piece.pos.col = to_col;
          if (moved.capture) {
            room.board.push(moved.capture)
          }
          break;
        }
      }
      break;
    }
  }

}