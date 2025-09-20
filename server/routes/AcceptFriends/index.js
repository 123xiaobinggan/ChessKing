// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');
const { ObjectId } = require('mongodb');

async function main(req, context) {
  const { myAccountId, opponentAccountId } = req.body;
  const db = await connectDB();
  const userCollection = db.collection('UserInfo');

  try {
    // 查询双方用户
    const [myUser, opponentUser] = await Promise.all([
      userCollection.findOne({ accountId: myAccountId }),
      userCollection.findOne({ accountId: opponentAccountId }),
    ]);

    if (!myUser || !opponentUser) {
      throw new Error('用户不存在');
    }

    // 从请求列表中移除
    await Promise.all([
      userCollection.updateOne(
        { _id: new ObjectId(myUser._id) },
        { $pull: { requestFriends: opponentAccountId } }
      ),
      userCollection.updateOne(
        { _id: new ObjectId(opponentUser._id) },
        { $pull: { requestFriends: myAccountId } }
      ),
    ]);

    // 添加到好友列表
    await Promise.all([
      userCollection.updateOne(
        { _id: new ObjectId(myUser._id) },
        { $addToSet: { friends: opponentAccountId } } // 用 $addToSet 防止重复
      ),
      userCollection.updateOne(
        { _id: new ObjectId(opponentUser._id) },
        { $addToSet: { friends: myAccountId } }
      ),
    ]);

    return { code: 0, msg: '成功添加好友' };
  } catch (error) {
    console.error('添加好友失败:', error);
    return { code: 1, msg: error.message || '添加好友失败' };
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
