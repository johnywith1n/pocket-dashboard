Datastore  = require('nedb')
logger = require('./logger.js').logger

articlesDb = new Datastore {filename: 'articles.db', nodeWebkitAppName: 'pocket-dashboard', autoload: true }
articlesDb.ensureIndex { fieldName: 'item_id' }, (err) ->
    if err?
        logger.error "Articles database index constraint error"
        logger.error err
    return

metadataDb = new Datastore {filename: 'metadata.db', nodeWebkitAppName: 'pocket-dashboard', autoload: true }

exports.upsertArticle = (doc) ->
    if doc.status is "2"
        articlesDb.remove {"item_id" : {$in : [doc.item_id]}}, (err, numRemove) ->
            if err?
                logger.error "Error removing document" + doc.item_id
                logger.error err
            else
                logger.info "Removed document: " + doc.item_id
            return
    else
        articlesDb.update {"item_id" : {$in : [doc.item_id]}}, doc,  { upsert: true }, (err, numReplaced, upsert) ->
            if err?
                logger.error "Error inserting document" + doc.item_id
                logger.error err
            else
                logger.info "Inserted document: " + doc.item_id
                logger.info "numReplaced : " + numReplaced + " - upsert : " + upsert
            return
    return

exports.updateLastSinceTimestamp = (time) ->
    metadataDb.update {"lastSince" : {$exists : true}}, {"lastSince" : time},  { upsert: true }, (err, numReplaced, upsert) ->
        if err?
            logger.error "Error updating the timestamp for last retrieving articles" + time
            logger.error err
        else
            logger.info "Updated last since timestamp for retrieving articles: " + time
        return
    return

exports.getLastSinceTimestamp = (callback) ->
    metadataDb.find {"lastSince" : {$exists : true}}, (findError, docs) ->
        if err?
            logger.error "Error find last since timestamp"
            logger.error err
            callback null
        else
            if docs.length is 0
                callback null
            else
                callback docs[0].lastSince
        return
    return
