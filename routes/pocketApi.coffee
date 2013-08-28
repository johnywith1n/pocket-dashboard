https = require 'https'
pocketOAuth = require './pocketOAuth.js'
db = require '../database.js'
logger = (require '../logger.js').logger

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
            statusCode = response.statusCode
            if statusCode is 200
                if json.list? and (Object.prototype.toString.call json.list) is "[object Object]"
                    for id, obj of json.list
                        db.upsertArticle obj
                    getItemsSinceWithOffset res, offset + MAX_ARTICLES_PER_CALL, since
                else
                    res.charset = 'utf-8'
                    json = {
                        "status" : "success",
                        "payload" : null
                        }
                    res.json json
                    db.updateLastSinceTimestamp json.since
            else
                switch statusCode
                    when 400 then error = "Invalid API request. This is probably an error with the app. Please report it on Github along with the log."
                    when 401 then error = "Problem authenticating user. Please refresh the page and log in again."; delete pocketOAuth["access_token"];
                    when 403 then error = "Rate limited. Please try again in an hour."
                    when 503 then error = "Pocket is down. Please try again later."
                    else error = "Unknown error code " + statusCode + ". Please report it on Github along with the log."
                logger.error "Error code " + statusCode + ". Response Header: " + JSON.stringify(res.headers)
                json = {
                            "status" : "error",
                            "error" : error,
                            "statusCode" : statusCode
                        }
                res.charset = 'utf-8'
                res.json json
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