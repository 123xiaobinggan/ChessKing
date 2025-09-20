// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const connectDB = require('../../db');
const { ObjectId } = require("bson");

// 更新段位的辅助函数（原来云函数里是调用 UpdateLevel，这里直接写逻辑或通过另一个接口调用）
async function updateLevel(db, accountId, Type, win) {
  const userCollection = db.collection('UserInfo');

  // 先更新基本统计
  let update = {};
  if (win === 1) {
    update = { $inc: { [`${Type}.win`]: 1, [`${Type}.total`]: 1, [`${Type}.levelBar`]: 10, [`activity`]: 10 } };
  } else if (win === -1) {
    update = { $inc: { [`${Type}.lose`]: 1, [`${Type}.total`]: 1, [`${Type}.levelBar`]: -10, [`activity`]: 10 } };
  } else {
    update = { $inc: { [`${Type}.total`]: 1, [`activity`]: 10 } };
  }
  try {
    await userCollection.updateOne({ accountId }, update);

    // 再查最新数据
    const user = await userCollection.findOne({ accountId: accountId });
    console.log('accountId', accountId);
    console.log('user', user);
    if (!user) {
      return;
    }
    let { levelBar, level } = user[Type];
    if (level === 0) {
      return; // 已经在最低级
    }

    let [dan, step] = level.toString().split("-").map(Number);

    // --- 升级 ---
    while (levelBar >= 100) {
      levelBar -= 100;
      step++;
      if (step > 3) {
        step = 1;
        dan++;
      }
    }

    // --- 降级 ---
    while (levelBar < 0) {
      if (dan === 1 && step === 1) {
        // 到最低级
        levelBar = 0;
        break;
      } else {
        step--;
        if (step < 1) {
          step = 3;
          dan--;
        }
        levelBar += 100; // 借位，相当于 90,80...
      }
    }

    // 更新回数据库
    const newLevel = `${dan}-${step}`;
    await userCollection.updateOne(
      { accountId },
      {
        $set: {
          [`${Type}.level`]: newLevel,
          [`${Type}.levelBar`]: levelBar
        }
      }
    );

    console.log(`✅ 更新完成：${newLevel}, levelBar=${levelBar}`);
  } catch (e) {
    console.log(e)
  }
}


async function main(req, context) {
  try {
    const db = await connectDB();
    const { roomId, type, result } = req.body;
    console.log('result', result);
    const roomCollection = db.collection('Room');
    const roomRes = await roomCollection.findOne({ _id: new ObjectId(roomId) });

    if (!roomRes) {
      return { code: 1, msg: '房间不存在' };
    }
    if (roomRes.status === 'finished') {
      return { code: 1, msg: '房间已结束' };
    }

    const player1 = roomRes.player1;
    const player2 = roomRes.player2;

    var Type;
    if (type.includes('ChineseChess')) {
      Type = "ChineseChess";
    } else if (type.includes('Military')) {
      Type = "Military";
    } else if (type.includes("Go")) {
      Type = "Go";
    } else {
      Type = "Fir";
    }
    await updateLevel(db, player1.accountId, Type,
      result.winner === player1.accountId ? 1 :
        result.winner === player2.accountId ? -1 : 0
    );

    await updateLevel(db, player2.accountId, Type,
      result.winner === player2.accountId ? 1 :
        result.winner === player1.accountId ? -1 : 0
    );

    await roomCollection.updateOne(
      { _id: new ObjectId(roomId) },
      {
        $set: {
          status: 'finished',
          result: result,
          finished_at: new Date()
        }
      }
    );

    return { code: 0, msg: '更新房间状态成功', data: { roomId } };
  } catch (err) {
    console.error(err);
    return { code: 1, msg: '更新房间状态失败', error: err.message };
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
