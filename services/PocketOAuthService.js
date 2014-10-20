'use strict';

var Keys = require('./KeysService');
var Urls = require('./UrlsService');
var Promise = require("bluebird");
var request = Promise.promisifyAll(require("request"));

module.exports.requestToken = function () {
  var params = {
    url: Urls.HOST + Urls.REQUEST_PATH,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Accept': 'application/json'
    },
    body: JSON.stringify({
      "consumer_key": Keys.consumerKey,
      "redirect_uri":  Urls.REDIRECT_URI
    })
  };

  return request.postAsync(params).then(function (res) {
    return JSON.parse(res[1]).code;
  });
};

module.exports.pocketOAuthCallback = function () {
  var params = {
    url:  Urls.HOST +  Urls.AUTHORIZE_PATH,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Accept': 'application/json'
    },
    body: JSON.stringify({
      "consumer_key": Keys.consumerKey,
      "code": Keys.requestToken
    })
  };

  return request.postAsync(params).then(function (res) {
    var body = JSON.parse(res[1]);
    if (body.access_token) {
      return body.access_token;
    } else {
      return new Error('Missing accessToken. Response was: ' + res[1]);
    }
  });
};

module.exports.isAuthorized = function () {
  return typeof Keys.accessToken !== "undefined" && Keys.accessToken !== null;
};
