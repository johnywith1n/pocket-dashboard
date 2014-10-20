'use strict';

var express = require('express');
var router = express.Router();
var Keys = require('../services/KeysService');
var logger = require('../logger').logger;
var db = require('../database/database');
var PocketApiService = require('../services/PocketApiService');
var Constants = require('../services/ConstantsService');
var _ = require('lodash');

function createErrorFromStatusCode (statusCode) {
  var error;

  if (statusCode === 400) {
    error = 'Invalid API request. This is probably an error with the app. Please report it on Github along with the log.';
  } else if (statusCode === 401) {
    error = 'Problem authenticating user. Please refresh the page and log in again.';
    delete Keys['access_token'];
  } else if (statusCode === 403) {
    error = 'Rate limited. Please try again in an hour.';
  } else if(statusCode === 503) {
    error = 'Pocket is down. Please try again later.';
  } else {
    error = 'Unknown error code ' + statusCode + '. Please report it on Github along with the log.';
  }

  return error;
}

function getItemsSinceWithOffset (res, offset, since) {
  PocketApiService.getItemsSinceWithOffset(offset, since).then(function (resArray) {
    var statusCode, json, error;

    statusCode = resArray[0].statusCode;

    if (statusCode === 200) {
      json = JSON.parse(resArray[1]);

      if(json.list != null && Object.prototype.toString.call(json.list) === '[object Object]') {
        _.forOwn(json.list, function (article) {
          db.updateArticle(article);
        });

        return getItemsSinceWithOffset(res, offset + Constants.MAX_ARTICLES_PER_CALL, since);
      } else {
        db.updateLastSinceTimestamp(json.since);

        res.json({
          'status' : 'success',
          'payload' : 'Successfuly updated articles.'
        });
      }
    } else {
      error = createErrorFromStatusCode(statusCode);

      logger.error('Error code ' + statusCode + '. Response Header: ' + JSON.stringify(res.headers));

      res.status(statusCode).json({
        'status' : 'error',
        'error' : error,
        'statusCode' : statusCode
      });
    }
  }).catch(function (err) {
    logger.error(err);
    res.status(500).send(err);
  });
}

router.get('/api/itemsSince', function (req, res) {
  res.charset = 'utf-8';

  db.getLastSinceTimestamp(function (since) {
    getItemsSinceWithOffset(res, 0, since);
  });
});

module.exports = router;