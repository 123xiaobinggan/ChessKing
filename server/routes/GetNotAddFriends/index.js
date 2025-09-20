// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
  const { friends } = req.body; // 已有好友列表
  const db = await connectDB();
  const userCollection = db.collection('UserInfo');

  try {
    // 查找不在好友列表中的用户，限制10个
    const users = await userCollection
      .find({ accountId: { $nin: friends || [] } })
      .limit(10)
      .toArray();

    if (users.length === 0) {
      return { code: 1, msg: '已加载所有用户' };
    }

    // 删除密码字段
    users.forEach((item) => {
      delete item.password;
    });

    // console.log('users', users);

    return { code: 0, msg: '获取成功', data: users };
  } catch (error) {
    console.error('查询用户失败:', error);
    return { code: 1, msg: '获取失败', error: error.message };
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
