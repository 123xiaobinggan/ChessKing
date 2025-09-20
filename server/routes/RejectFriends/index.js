const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
  const { myAccountId, opponentAccountId } = req.body || {};
  const db = await connectDB();
  const userCollection = db.collection('UserInfo');

  try {
    // 查找当前用户
    const myUser = await userCollection.findOne({ accountId: myAccountId });
    if (myUser && myUser.requestFriends?.includes(opponentAccountId)) {
      // 从 requestFriends 数组中移除 opponentAccountId
      await userCollection.updateOne(
        { _id: myUser._id },
        { $pull: { requestFriends: opponentAccountId } }
      );
      return { code: 0, msg: '已拒绝' };
    }

    return { code: 1, msg: '未找到该请求' };
  } catch (error) {
    console.error(error);
    return { code: 1, msg: '拒绝失败' };
  }
}

router.post('/', async (req, res) => {
  try {
    const result = await main(req, {});
    res.json(result);
  } catch (err) {
    console.log('err', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
