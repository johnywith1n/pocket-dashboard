db = require '../database.js'
dbQuery = require '../databaseQueries.js' 

exports.getCounts = (req, res) ->
    queryParam = req.query.query
    switch queryParam
        when "unarchived" then query = dbQuery.getUnarchived()
        when "archived" then query = dbQuery.getArchived()
        else query = dbQuery.getAll()
    db.getCounts query, (count) ->
        res.charset = 'utf-8'
        res.json { "count" : count.toString() }