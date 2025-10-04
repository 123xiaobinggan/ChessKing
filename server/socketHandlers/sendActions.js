const { ObjectId } = require('bson');
const { cancelAI } = require('../pikafish.js')

module.exports = (io, socket, roomCollection, accountIdMap) => {
  socket.on('sendActions', async (action) => {
    console.log('sendActions', action);
    cancelAI();
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
          io.to(socket.data.socketRoomId).emit('receiveActions', {
            roomId: room.id,
            accountId: room.player2.accountId,
            type: "同意悔棋"
          });
          undo(room, action.accountId);
          await roomCollection.updateOne(
            { _id: new ObjectId(room._id) },
            {
              $set: { board: room.board, moves: room.moves }
            },
          );
        } else if (action.type == "请求和棋") {
          io.to(socket.data.socketRoomId).emit('receiveActions', {
            roomId: room.id,
            accountId: room.player2.accountId,
            type: "请求和棋"
          });
        }
        return;
      }
    }
    io.to(socket.data.socketRoomId).emit('receiveActions', action);
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
      console.log('moved', moved);
      if (!moved.isRed) {
        from_row = 9 - from_row;
        from_col = 8 - from_col;
        to_row = 9 - to_row;
        to_col = 8 - to_col;
      }
      for (var j = 0; j < room.board.length; j++) {
        var piece = room.board[j];
        if (piece.type == moved.type && piece.isRed == moved.isRed && piece.pos.row == from_row && piece.pos.col == from_col) {
          piece.pos.row = to_row;
          piece.pos.col = to_col;
          if (moved.capture) {
            room.board.push(moved.capture)
          }
          console.log('piece', piece);
          break;
        }
      }
      break;
    }
  }
  room.moves.pop();
  console.log('room.moves', room.moves)
}
