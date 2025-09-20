// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');  // 连接 MongoDB

// 构建多个正则匹配模式
function buildPatterns(keyword) {
    const patterns = [];

    // 单个字符匹配
    for (let i = 0; i < keyword.length; i++) {
        patterns.push(keyword[i]);
    }

    // 顺序部分匹配
    for (let i = 0; i < keyword.length; i++) {
        for (let j = i + 1; j < keyword.length; j++) {
            const sub = keyword.slice(i, j + 1).split('').join('.*');
            patterns.push(sub);
        }
    }

    return patterns;
}

async function main(req, context) {
    const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
    const { keyword } = body;

    const db = await connectDB();
    const userCollection = db.collection('UserInfo');

    // 先用“最宽松”的正则查询
    const regex = new RegExp(`.*${keyword}.*`, 'i');

    const users = await userCollection
        .find({ accountId: { $regex: regex } })
        .toArray();

    // 在代码层面计算匹配程度
    const patterns = buildPatterns(keyword);
    const matchedUsers = users.map(user => {
        let score = 0;
        for (const pat of patterns) {
            if (new RegExp(pat, 'i').test(user.accountId)) {
                score = Math.max(score, pat.length); // 匹配越长得分越高
            }
        }
        return { ...user, score };
    });

    // 按匹配度排序
    matchedUsers.sort((a, b) => b.score - a.score);

    return { code: 0, msg: '查询成功', data: matchedUsers };
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
