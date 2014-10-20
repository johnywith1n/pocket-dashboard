'use strict';

var Keys = require('./KeysService');
var Urls = require('./UrlsService');
var Constants = require('../services/ConstantsService');
var Promise = require('bluebird');
var request = Promise.promisifyAll(require('request'));

var MAX_ARTICLES_PER_CALL = 5000;

module.exports.getItemsSinceWithOffset = function (offset, since) {
  var body = {
    'state' : 'all',
    'consumer_key' : Keys.consumerKey,
    'access_token' : Keys.accessToken,
    'count' : Constants.MAX_ARTICLES_PER_CALL,
    'offset' : offset
  };

  if (since) {
    body.since = since;
  }

  var params = {
    url: Urls.HOST + Urls.GET_PATH,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Accept': 'application/json'
    },
    body: JSON.stringify(body)
  };

  return request.postAsync(params);
}
