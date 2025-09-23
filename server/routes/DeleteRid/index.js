// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
  try {
    const db = await connectDB();
    const { accountId } = req.body;

    const userCollection = db.collection('UserInfo');

    // 查询用户
    const user = await userCollection.findOne({ accountId });
    if (!user) {
      return { code: 1, msg: '用户不存在' };
    }

    // 构造更新数据
    const data = {
      rid: ""
    };

    // 更新用户rid信息
    await userCollection.updateOne(
      { _id: user._id },
      { $set: data }
    );
    console.log('更新成功');
    return { code: 0, msg: '更新成功' };
  } catch (err) {
    console.error('更新用户信息失败:', err);
    return { code: 1, msg: '修改失败', error: err.message };
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
