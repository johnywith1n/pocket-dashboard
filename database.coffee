Pouch = require('pouchdb')
db = new PouchDB("database")

exports.addDoc = (doc,callback) ->
    return db.put doc, callback

exports.getAllDocs = (options, callback) ->
    return db.allDocs(options, callback)
