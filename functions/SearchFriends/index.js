const tcb = require('@cloudbase/node-sdk');

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
});


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

exports.main = async (event, context) => {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
    const { keyword } = body;

    const db = app.database();
    const userCollection = db.collection('UserInfo');

    // 生成多个正则
    const patterns = buildPatterns(keyword);

    // 先用“最宽松”的正则查询（只要包含 keyword 任意字符）
    const regex = db.RegExp({
        regexp: `.*${keyword}.*`,
        options: 'i'
    });

    const userDoc = await userCollection.where({
        accountId: regex
    }).get();



    const users = userDoc.data;

    // 在代码层面计算匹配程度
    const matchedUsers = users.map(user => {
        let score = 0;
        for (const pat of patterns) {
            if (new RegExp(pat, 'i').test(user.accountId)) {
                score = Math.max(score, pat.length); // 匹配越长得分越高
            }
        }
        return { ...user, score };
    });

    matchedUsers.sort((a, b) => b.score - a.score);

    return { code: 0, msg: '查询成功', data: matchedUsers };
};
