'use strict';

var express = require('express');
var router = express.Router();
var Keys = require('../services/KeysService');
var Urls = require('../services/UrlsService');
var PocketOAuth = require('../services/PocketOAuthService');

router.get('/api/requestToken', function (req, res) {
  PocketOAuth.requestToken().then(function (code) {
    Keys.requestToken = code;
    res.redirect('https://getpocket.com/auth/authorize?request_token=' + Keys.requestToken +
      '&redirect_uri=' + encodeURIComponent(Urls.REDIRECT_URI));
  }).catch(function (e) {
    console.error(e);
    res.send(500, e);
  });
});

router.get('/api/pocketOAuthCallback', function (req, res) {
  PocketOAuth.pocketOAuthCallback().then(function (accessToken) {
    Keys.accessToken = accessToken;
    res.redirect(Urls.CALLBACK_URI);
  }).catch(function (e) {
    console.error(e);
    res.send(500, e);
  });
});

router.get('/api/isAuthorized', function (req, res) {
  res.charset = 'utf-8';
  return res.json({
    "status": "success",
    "payload": { isAuthorized: PocketOAuth.isAuthorized() }
  });
});

module.exports = router;
