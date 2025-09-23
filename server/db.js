// db.js
const { MongoClient } = require('mongodb');

const url = 'mongodb://{数据库名称}:{服务器密码}{服务器地址+工作文件夹}'; // 改成你的数据库地址
const client = new MongoClient(url);

async function connectDB() {
  if (!client.topology?.isConnected()) {
    await client.connect();
  }
  return client.db('{数据库名}'); // 改成你的数据库名
}

module.exports = connectDB;
