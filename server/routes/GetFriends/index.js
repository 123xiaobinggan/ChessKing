// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db'); // 引入数据库连接

async function main(req, context) {
  const { accountId } = req.body;
  console.log('查找其friends和requestFriends', accountId);
  const db = await connectDB();
  const userCollection = db.collection('UserInfo');

  try {
    const user = await userCollection.findOne({ accountId });
    if (!user) {
      throw new Error('用户不存在');
    }

    const friends = user.friends || [];
    const requestFriends = user.requestFriends || [];
    // 查找所有好友和请求中的用户
    const friendsDocs = await userCollection
      .find({
        accountId: { $in: [...friends] },
      })
      .toArray();
    
    const requestFriendsDocs = await userCollection
      .find({
        accountId: { $in: [...requestFriends] },
      })
      .toArray();

    const friendsList = friendsDocs.map((item) => {
      const { password, ...rest } = item; // 去掉密码
      return rest;
    });

    const requestFriendsList = requestFriendsDocs.map((item) => {
        const {password, ...rest } = item
        return rest 
    })

    return { code: 0, msg: '获取成功', data: {friendsList,requestFriendsList} };
  } catch (err) {
    console.log('获取失败', err);
    return { code: 1, msg: err.message || '获取失败' };
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
