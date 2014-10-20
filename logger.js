'use strict';

var log4js = require('log4js');

 log4js.configure({
  appenders: [
    {
      type: 'file',
      filename: 'myLog.log',
      category: 'myLog'
    }
  ]
});

  var logger = log4js.getLogger('myLog');

  logger.setLevel('debug');

  module.exports.logger = logger;