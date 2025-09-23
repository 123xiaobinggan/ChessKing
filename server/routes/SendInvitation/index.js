// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');
const JPush = require('jpush-sdk');

// 初始化极光客户端
const client = JPush.buildClient(
  '74dacc1e2e26774220395b0e',
  '4de60b2fb9fda99e39c12292'
);

async function main(req, context) {

  const { accountId, invitation } = req.body;

  const db = await connectDB();
  const userCollection = db.collection('UserInfo');

  // 查找被邀请用户的 registrationId
  let rid = '';
  try {
    const userDoc = await userCollection.findOne({ accountId: accountId });
    if (userDoc) {
      rid = userDoc.rid;
    } else {
      return { code: 1, msg: '被邀请用户不存在' };
    }
  } catch (err) {
    console.error(err);
    return { code: 1, msg: '查询用户失败' };
  }

  if (!rid) {
    return { code: 1, msg: "用户未登录" };
  }
  // 发送推送
  try {
    await sendInvite(
      rid,
      invitation.type,
      invitation.accountId,
      invitation.gameTime,
      invitation.stepTime
    );
    return { code: 0, msg: '推送已发送' };
  } catch (err) {
    console.error(err);
    return { code: 1, msg: '推送失败' };
  }
}

function sendInvite(registrationId, type, fromUser, gameTime, stepTime) {
  return new Promise((resolve, reject) => {
    client
      .push()
      .setPlatform('android')
      .setAudience(JPush.registration_id(registrationId))
      .setNotification(
        typeTransfer(type), // 通知标题
        JPush.android(
          `${fromUser}:邀请你弈棋，点击迎战`, // 通知内容
          typeTransfer(type), // Android 通知标题
          1, // 通知角标
          { type: type, accountId: fromUser, gameTime, stepTime } // extras
        )
      )
      .send((err, res) => {
        if (err) {
          console.error(err);
          reject(err);
        } else {
          console.log('推送结果:', res);
          resolve(res);
        }
      });
  });
}

// 根据棋类类型映射标题
function typeTransfer(type) {
  if (type.includes('ChineseChess')) return '中国象棋';
  else if (type.includes('Go')) return '围棋';
  else if (type.includes('Military')) return '军棋';
  else return '五子棋';
}

router.post('/', async (req, res) => {
  try {
    const result = await main(req, {});
    res.json(result);
  } catch (err) {
    console.error('err', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
