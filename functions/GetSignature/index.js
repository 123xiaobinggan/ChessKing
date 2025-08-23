const tcb = require('@cloudbase/node-sdk')
const COS = require('cos-nodejs-sdk-v5')

const app = tcb.init({
    env: 'chess-king-1gvhs90sfc60354d'
})

exports.main = async (event, context) => {
    const { accountId, filePath } = JSON.parse(event.body);
    const db = app.database();
    const cos = new COS({
        SecretId: 'AKIDjU9wWyEH7mIdmjV4SddAWiiYCi9RYTBg',
        SecretKey: 'SjrmnprjZIsGVXO1UlrjQwGTUIsENI2Y',
    })

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