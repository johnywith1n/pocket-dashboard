Datastore  = require('nedb')
db = new Datastore {filename: 'database.db', nodeWebkitAppName: 'pocket-dashboard', autoload: true }

exports.insert = (doc,callback) ->
    return db.insert doc, callback


