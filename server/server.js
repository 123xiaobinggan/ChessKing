const express = require('express')
const fs = require('fs');
const path = require('path');

const app = express();
const http = require("http");
const { Server } = require("socket.io");
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" }, // 允许跨域
  pingInterval: 1000,
  pingTimeout: 3000
});

const port = 3000;

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
const registerSendInvitationHandler = require('./socketHandlers/sendInvitation');
const registerDealInvitationHandler = require('./socketHandlers/dealInvitation');
const registerCancelMatchHandler = require('./socketHandlers/cancelMatch');
const registerSendMessagesHandler = require('./socketHandlers/sendMessages');
const registerSendActionsHandler = require('./socketHandlers/sendActions');


let accountIdMap = {}
let waitingPlayers = [];
const connectDB = require('./db');
(async () => {
  const db = await connectDB(); // 初始化一次
  const roomCollection = db.collection('Room');
  const userCollection = db.collection('UserInfo');

  io.on('connection', (socket) => {
    const { accountId } = socket.handshake.auth;
    accountIdMap[accountId] = socket
    socket.accountId = accountId
    console.log('新请求连接', accountId, socket.id, Object.values(accountIdMap).map(socket => socket.id));

    //ChineseChessMatch
    registerChineseChessMatchHandler(io, socket, db, waitingPlayers, roomCollection);
    //ChineseChessWithFriends
    registerChineseChessWithFriendsHandle(io, socket, db, waitingPlayers, roomCollection);
    //ChineseChessAi
    registerChineseChessAiHandle(io, socket, db, roomCollection);
    //落子
    registerMoveHandler(io, socket, db, roomCollection);
    //断线重连
    registerReconnectHandler(io, socket, db, accountIdMap, roomCollection);
    //断线
    registerDisconnectHandler(io, socket, db, waitingPlayers, accountIdMap, roomCollection);
    //取消匹配
    registerCancelMatchHandler(io, socket, roomCollection,waitingPlayers);
    //发送邀请
    registerSendInvitationHandler(io, socket, userCollection, roomCollection, accountIdMap);
    //接收邀请
    registerDealInvitationHandler(io, socket, userCollection, roomCollection, accountIdMap);
    // 发送消息
    registerSendMessagesHandler(io,socket,roomCollection,accountIdMap);
    // 发送actions
    registerSendActionsHandler(io,socket,roomCollection,accountIdMap);
  });

})()

server.listen(port, "0.0.0.0", () => {
  console.log(`✅ Server running at http://0.0.0.0:${port}`);
});
