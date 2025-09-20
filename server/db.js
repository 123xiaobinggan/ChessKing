// db.js
const { MongoClient } = require('mongodb');

const url = 'mongodb://chessUser:{password}{服务器ip}/ChessKing'; // 改成你的数据库地址
const client = new MongoClient(url);

async function connectDB() {
  if (!client.topology?.isConnected()) {
    await client.connect();
  }
  return client.db('ChessKing'); // 改成你的数据库名
}

module.exports = connectDB;
