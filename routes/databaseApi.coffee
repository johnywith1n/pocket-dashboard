db = require '../database.js'
dbQuery = require '../databaseQueries.js' 
urlLibrary = require 'url'

cleanDocument = (doc) ->
    delete doc['item_id']
    delete doc['resolved_id']
    delete doc['given_url']
    delete doc['given_title']
    delete doc['favorite']
    delete doc['time_favorited']
    delete doc['sort_id']
    delete doc['excerpt']
    delete doc['is_article']
    delete doc['is_index']
    delete doc['has_video']
    delete doc['has_image']
    delete doc['word_count']
    delete doc['_id']
    return doc

getQueryFromStatus = (status) ->
    switch status
        when "unarchived" then query = dbQuery.getUnarchived()
        when "archived" then query = dbQuery.getArchived()
        when "all" then query = dbQuery.getAll()
        else query = dbQuery.getAll()

exports.getCounts = (req, res) ->
    db.getCounts (getQueryFromStatus req.query.status), (count) ->
        res.charset = 'utf-8'
        if count?
            res.json {  
                "status" : "success",
                "payload" : {
                    "count" : count.toString()
                } 
            }
        else
            res.json {
                "status" : "error"
                "error" : "Failed to get count from database."
            }
        return
    return



exports.getArticlesByUrl = (req, res) ->
    db.getArticles (getQueryFromStatus req.query.status), (articles) ->
        res.charset = 'utf-8'
        if articles?
            articlesByUrl = {}
            for article in articles
                if article.hasOwnProperty "resolved_url"
                    articleUrl = article.resolved_url
                else
                    articleUrl = article.given_url
                host = (urlLibrary.parse articleUrl).hostname
                if articlesByUrl.hasOwnProperty host
                    articlesByUrl[host] = articlesByUrl[host] + 1
                else
                    articlesByUrl[host] = 1
            countsArray = []
            for url, count of articlesByUrl
                countsArray.push {url: url, count: count}
            res.json {
                "status" : "success",
                "payload" : {
                    "articlesByUrl" : countsArray
                }
            }
        else
            res.json {
                "status" : "error"
                "error" : "Failed to get articles by url from database"
            }
        return
    return