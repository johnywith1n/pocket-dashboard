'use strict';

var Datastore = require('nedb');
var logger = require('../logger.js').logger;

var articlesDb = new Datastore({
  filename: 'articles.db',
  autoload: true
});

var metadataDb = new Datastore({
  filename: 'metadata.db',
  autoload: true
});

articlesDb.ensureIndex({ fieldName: 'item_id' }, function (err) {
  if (err) {
    logger.error("Articles database index constraint error");
    logger.error(err);
  }
});

module.exports.updateArticle = function (doc) {
  if (doc.status === '2') {
    articlesDb.remove({ 'item_id' : { $in : [doc.item_id] } }, function (err, numRemoved) {
      if (err) {
        logger.error('Error removing document' + doc.item_id);
        logger.error(err);
      } else {
        logger.info('Removed document: ' + doc.item_id + ' -  numRemove: ' + numRemoved);
      }
    });
  } else {
    articlesDb.update({ 'item_id' : {$in : [doc.item_id] } },
      doc, { upsert: true }, function (err, numReplaced, upsert) {
      if (err) {
        logger.error('Error inserting document' + doc.item_id);
        logger.error(err);
      } else {
        logger.info('Inserted document: ' + doc.item_id);
        logger.info('numReplaced : ' + numReplaced + ' - upsert : ' + upsert);
      }
    });
  }
}

module.exports.updateLastSinceTimestamp = function (time) {
  metadataDb.update({ 'lastSince' : { $exists : true } }, { 'lastSince' : time },
    { upsert: true }, function (err, numReplaced, upsert) {
    if (err) {
      logger.error('Error updating the timestamp for last retrieving articles' + time);
      logger.error(err);
    } else {
      logger.info('Updated last since timestamp for retrieving articles: ' + time);
    }
  });
}

module.exports.getLastSinceTimestamp = function (cb) {
  metadataDb.find({ 'lastSince' : { $exists : true } }, function (err, docs) {
    if (err) {
      logger.error('Error find last since timestamp');
      logger.error(err);
      cb(null);
    } else {
      if (docs.length === 0) {
        cb(null);
      } else{
        cb(docs[0].lastSince);
      }
    }
  });
}

module.exports.getCounts = function (query, cb) {
  articlesDb.count(query, function (err, count) {
    if (err) {
      logger.error('Error getting count for query: ' + JSON.stringify(query));
      cb(null);
    } else{
      cb(count);
    }
  });
}

module.exports.getArticles = function (query, cb) {
  articlesDb.find(query, function (err, docs) {
    if (err) {
      logger.error('Error getting articles for query: ' + JSON.stringify(query));
      cb([]);
    } else{
      cb(docs);
    }
  });
}
