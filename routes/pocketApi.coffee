https = require 'https'
pocketOAuth = require('./pocketOAuth.js')
db = require('../database.js')
logger = require('../logger.js').logger

HOST = "getpocket.com"
GET_PATH = "/v3/get"
MAX_ARTICLES_PER_CALL = 5000


getItemsSinceWithOffset = (res, offset, since) ->
    options = {
        host : HOST,
        path : GET_PATH,
        method : 'POST',
        headers : {
                'Content-Type' : 'application/json; charset=UTF-8',
                'X-Accept' : 'application/json'
        }
    }
    authReq = https.request options, (response) ->
        str = ''
        response.on 'data', (chunk) ->
            str += chunk
            return
        response.on 'end', () ->
            json = JSON.parse str
            if json.list? and (Object.prototype.toString.call json.list) is "[object Object]"
                for id, obj of json.list
                    db.upsertArticle obj
                getItemsSinceWithOffset res, offset + MAX_ARTICLES_PER_CALL, since
            else
                newList = []
                for id, obj of json.list
                    newList.push obj
                json.list = newList.sort (a,b) -> return a.time_added - b.time_added
                res.charset = 'utf-8'
                res.json json
                db.updateLastSinceTimestamp json.since
            return
        return
    params = {
        "state" : "all"
        "consumer_key" : pocketOAuth.consumerKey,
        "access_token" : pocketOAuth.accessToken,
        "count" : MAX_ARTICLES_PER_CALL,
        "offset" : offset
    }
    if since?
        params.since = since
    authReq.write JSON.stringify params
    authReq.end()
    return    

exports.getItemsSince = (req, res) ->
    db.getLastSinceTimestamp (since) ->
        getItemsSinceWithOffset res, 0, since
        return
    return