// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
  try {
    const db = await connectDB();
    const { accountId, username, avatar, description, password, newPassword } = req.body;

    const userCollection = db.collection('UserInfo');

    // 查询用户
    const user = await userCollection.findOne({ accountId });
    if (!user) {
      return { code: 1, msg: '用户不存在' };
    }

    // 校验密码（如果前端传了 password）
    if (password && user.password !== password) {
      return { code: 1, msg: '密码错误' };
    }

    // 构造更新数据
    const data = {
      username: username || user.username,
      avatar: avatar || user.avatar,
      description: description || user.description,
      password: newPassword || user.password,
    };

    // 更新用户信息
    await userCollection.updateOne(
      { _id: user._id },
      { $set: data }
    );

    return { code: 0, msg: '修改成功' };
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
