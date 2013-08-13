log4js = require 'log4js'

log4js.configure {
  appenders: [
    { type: 'file', filename: 'myLog.log', category: 'myLog' }
  ]
}

logger = log4js.getLogger 'myLog'
logger.setLevel 'debug'

exports.logger = logger