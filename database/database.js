'use strict';

var Datastore = require('nedb');
var logger = require('../logger.js').logger;
var Promise = require("bluebird");

var articlesDb = Promise.promisifyAll(new Datastore({
  filename: 'articles.db',
  autoload: true
}));

var metadataDb = Promise.promisifyAll(new Datastore({
  filename: 'metadata.db',
  autoload: true
}));

articlesDb.ensureIndexAsync({ fieldName: 'item_id' }).catch(function (err) {
  logger.error("Articles database index constraint error");
  logger.error(err);
});

module.exports.updateArticle = function (doc) {
  if (doc.status === '2') {
    articlesDb.removeAsync({ 'item_id' : { $in : [doc.item_id] } }).then(function (numRemoved) {
      logger.info('Removed document: ' + doc.item_id + ' -  numRemove: ' + numRemoved);
    }).catch(function (err) {
      logger.error('Error removing document' + doc.item_id);
      logger.error(err);
    });
  } else {
    articlesDb.updateAsync({ 'item_id' : {$in : [doc.item_id] } }, doc, { upsert: true }).then(function (res) {
      var numReplaced, upsert;

      numReplaced = res[0];
      upsert = res[1];

      logger.info('Inserted document: ' + doc.item_id);
      logger.info('numReplaced : ' + numReplaced + ' - upsert : ' + upsert);
    }).catch(function (err) {
      logger.error('Error inserting document' + doc.item_id);
      logger.error(err);
    });
  }
}

module.exports.updateLastSinceTimestamp = function (time) {
  metadataDb.updateAsync({ 'lastSince' : { $exists : true } }, { 'lastSince' : time },
    { upsert: true }).then(function () {
    logger.info('Updated last since timestamp for retrieving articles: ' + time);
  }).catch(function (err) {
    logger.error('Error updating the timestamp for last retrieving articles' + time);
    logger.error(err);
  });
}

module.exports.getLastSinceTimestamp = function () {
  return metadataDb.findAsync({ 'lastSince' : { $exists : true } }).then(function (docs) {
    if (docs.length === 0) {
      return null;
    } else {
      return docs[0].lastSince;
    }
  }).catch(function (err) {
    logger.error('Error find last since timestamp');
    logger.error(err);
    return null;
  });
}

module.exports.getCounts = function (query) {
  return articlesDb.countAsync(query);
}

module.exports.getArticles = function (query) {
  return articlesDb.findAsync(query);
}
