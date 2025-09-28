const express = require('express');
const router = express.Router();
const connectDB = require('../../db');

async function main(req, context) {
    try {
        const { accountId } = req.body;
        const db = await connectDB();

        const conversationCollection = db.collection('Conversation');
        const userCollection = db.collection('UserInfo')
        const conversations = await conversationCollection
            .find({ members: accountId }) // 我参与的会话
            .sort({ lastTime: -1 })    // 按最近活跃排序
            .toArray();
        console.log()
        const opponentAccountIds = [
            ...new Set(conversations.flatMap(c => c.members[0] == accountId ? c.members[1] : c.members[0]))
        ];

        // 查询这些用户的资料
        const opponentUsers = await userCollection
            .find({ accountId: { $in: opponentAccountIds } })
            .project({ accountId: 1, username: 1, avatar: 1 })
            .toArray();

        // 转成 map，方便查找
        const opponentUserMap = {};
        opponentUsers.forEach(u => {
            opponentUserMap[u.accountId] = u;
        });

        const result = conversations.map(c => {
            const otherId = c.members.find(m => m !== accountId);
            return {
                conversationId: c._id,
                lastMessage: c.lastMessage,
                lastTime: c.lastTime,
                unreadCnt: c.unreadCnt?.[accountId] || 0,
                opponent: opponentUserMap[otherId] || {}
            };
        });

        return { code: 0, conversations:result };

    } catch (e) {
        console.log('e', e);
        return { code: 1, msg: e }
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
