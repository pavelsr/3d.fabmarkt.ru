var TelegramBot = require('node-telegram-bot-api');
var token = '237382088:AAE8edrqW4h02Zfj8vSNv3Hyoix49_3Dx94';

var options = {
  webHook: {
    port: 443,
    key: __dirname+'/secret.key',
    cert: __dirname+'/server.crt'
  }
};

var bot = new TelegramBot(token, options);
bot.setWebHook('', __dirname+'/server.crt');

