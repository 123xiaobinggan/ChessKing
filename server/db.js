// db.js
const { MongoClient } = require('mongodb');

const url = 'mongodb://chessUser:Qinguanqiao1356@120.48.156.237:27017/ChessKing'; // 改成你的数据库地址
const client = new MongoClient(url);

async function connectDB() {
  if (!client.topology?.isConnected()) {
    await client.connect();
  }
  return client.db('ChessKing'); // 改成你的数据库名
}

module.exports = connectDB;
