// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');
const { ObjectId } = require('mongodb');

async function main(req, context) {
  try {
    const db = await connectDB();
    const { myAccountId, opponentAccountId } = req.body;

    const userCollection = db.collection('UserInfo');

    // 查询双方用户
    const [myUser, opponentUser] = await Promise.all([
      userCollection.findOne({ accountId: myAccountId }),
      userCollection.findOne({ accountId: opponentAccountId }),
    ]);

    if (!myUser || !opponentUser) {
      return { code: 1, msg: '用户不存在' };
    }

    // 删除双方的好友关系 & 好友请求
    const [myRes, opponentRes] = await Promise.all([
      userCollection.updateOne(
        { _id: new ObjectId(myUser._id) },
        {
          $pull: {
            friends: opponentAccountId,
            requestFriends: opponentAccountId,
          },
        }
      ),
      userCollection.updateOne(
        { _id: new ObjectId(opponentUser._id) },
        {
          $pull: {
            friends: myAccountId,
            requestFriends: myAccountId,
          },
        }
      ),
    ]);

    if (myRes.modifiedCount > 0 || opponentRes.modifiedCount > 0) {
      return { code: 0, msg: '好友关系已删除' };
    } else {
      return { code: 1, msg: '未找到好友关系' };
    }
  } catch (error) {
    console.error('删除好友出错:', error);
    return { code: 1, msg: '删除失败', error: error.message };
  }
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
