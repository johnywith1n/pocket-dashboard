'use strict';

var url = require('url');
var express = require('express');
var router = express.Router();
var logger = require('../logger').logger;
var db = require('../database/database');
var queries = require('../database/queries');
var _ = require('lodash');

function getQueryFromStatus (status) {
  var query;

  if (status === 'unarchived') {
    query = queries.getUnarchived();
  } else if (status === 'archived') {
    query = queries.getArchived();
  } else if (status === 'all') {
    queries.getAll();
  } else {
    query = queries.getAll();
  }

  return query;
}

router.get('/api/getCounts', function (req, res) {
  res.charset = 'utf-8';

  db.getCounts(getQueryFromStatus(req.query.status)).then(function (count) {
    res.json({
      'status' : 'success',
      'payload' : {
          'count' : count.toString()
      }
    });
  }).catch(function (err) {
    logger.error('Error getting count for query: ' + JSON.stringify(query));
    logger.error(err);
    res.status(500).json({
      'status' : 'error',
      'error' : 'Failed to get count from database.'
    });
  });
});

router.get('/api/getArticlesByUrl', function (req, res) {
  res.charset = 'utf-8';

  db.getArticles(getQueryFromStatus(req.query.status)).then(function (articles) {
    var articlesByUrl, countsArray;

    articlesByUrl = {};

    _.forEach(articles, function (article) {
      var articleUrl, host;

      if (article.hasOwnProperty('resolved_url')) {
        articleUrl = article.resolved_url;
      } else {
        articleUrl = article.given_url;
      }

      host = url.parse(articleUrl).hostname;

      if (articlesByUrl.hasOwnProperty(host)) {
        articlesByUrl[host] = articlesByUrl[host] + 1;
      } else {
        articlesByUrl[host] = 1;
      }
    });

    countsArray = []

    _.forOwn(articlesByUrl, function (count, url) {
      countsArray.push( { url: url, count: count });
    });

    res.json({
        'status' : 'success',
        'payload' : {
            'articlesByUrl' : countsArray
        }
    });
  }).catch(function (err) {
    logger.error('Error getting articles for query: ' + JSON.stringify(query));
    logger.error(err);
    res.status(500).json({
        'status' : 'error',
        'error' : 'Failed to get articles by url from database'
    });
  });
});

module.exports = router;
