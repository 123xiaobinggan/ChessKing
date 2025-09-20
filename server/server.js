const express = require('express')
const fs = require('fs');
const path = require('path');

const app = express();
const http = require("http");
const { Server } = require("socket.io");
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" } // 允许跨域
});


const port = 3000;

app.get("/", (req, res) => {
  res.send("Hello, ChessKing Server is running!");
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const routesPath = path.join(__dirname, 'routes');
fs.readdirSync(routesPath).forEach(folder => {
  const routePath = path.join(routesPath, folder);
  if (fs.lstatSync(routePath).isDirectory()) {
    const route = require(path.join(routePath, 'index.js'));
    app.use(`/${folder}`, route);
  }
});

// 引入 socket 逻辑
const registerChineseChessMatchHandler = require('./socketHandlers/ChineseChessMatch');
const registerChineseChessAiHandle = require('./socketHandlers/ChineseChessAi');
const registerChineseChessWithFriendsHandle = require('./socketHandlers/ChineseChessWithFriends');
const registerMoveHandler = require('./socketHandlers/move');
const registerReconnectHandler = require('./socketHandlers/reconnect');
const registerDisconnectHandler = require('./socketHandlers/disconnect');
const registerHeartBeatHandler = require('./socketHandlers/heartBeat');

let waitingPlayers = [];
const connectDB = require('./db');
(async () => {
  const db = await connectDB(); // 初始化一次
  const roomCollection = db.collection('Room');

  io.on('connection', (socket) => {
    console.log('新请求连接', socket.id);

    //ChineseChessMatch
    registerChineseChessMatchHandler(io, socket, db, waitingPlayers, roomCollection);
    //ChineseChessWithFriends
    registerChineseChessWithFriendsHandle(io, socket, db, waitingPlayers, roomCollection);
    //ChineseChessAi
    registerChineseChessAiHandle(io, socket, db, roomCollection);
    //落子
    registerMoveHandler(io, socket, db, roomCollection);
    //断线重连
    registerReconnectHandler(io, socket, db,roomCollection);
    //断线
    registerDisconnectHandler(io, socket, db, waitingPlayers);
    //心跳
    registerHeartBeatHandler(io, socket, roomCollection);

  });

})()

server.listen(port, "0.0.0.0", () => {
  console.log(`✅ Server running at http://0.0.0.0:${port}`);
});
