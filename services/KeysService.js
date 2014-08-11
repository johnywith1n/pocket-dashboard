'use strict';

var fs = require('fs');

module.exports.consumerKey = fs.readFileSync('CONSUMER_KEY', 'utf8');
