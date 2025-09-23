// routes/OtherModule/index.js
const express = require('express');
const router = express.Router();
const COS = require('cos-nodejs-sdk-v5');

async function main(req, context) {
    const { accountId, filePath } = req.body;
    const cos = new COS({
        SecretId: 'AKIDjU9wWyEH7mIdmjV4SddAWiiYCi9RYTBg',
        SecretKey: 'SjrmnprjZIsGVXO1UlrjQwGTUIsENI2Y',
    })

    if (!accountId || !filePath) {
        throw new Error('缺少必要参数 accountId 或 filePath');
    }

    const key = filePath;

    try {
        // 使用 Promise 处理异步操作
        const url = cos.getObjectUrl({
            Bucket: 'binggan-1358387153',
            Region: 'ap-guangzhou',
            Key: key,
            Sign: true,
            Method: 'PUT',
            Expires: 60 // 有效期1分钟
        });
        console.log('res', url);
        return {
            url: url
        };
    } catch (err) {
        console.log(err);
        return {
            url: ''
        }
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
