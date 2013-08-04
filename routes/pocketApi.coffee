https = require 'https'
pocketOAuth = require('./pocketOAuth.js')
db = require('../database.js')
logger = require('../logger.js').logger

HOST = "getpocket.com"
GET_PATH = "/v3/get"

getItemsSince = (callback, since) ->
    options = {
        host : HOST,
        path : GET_PATH,
        method : 'POST',
        headers : {
                'Content-Type' : 'application/json; charset=UTF-8',
                'X-Accept' : 'application/json'
        }
    }
    authReq = https.request options, callback
    authReq.write JSON.stringify {
        "consumer_key" : pocketOAuth.consumerKey,
        "access_token" : pocketOAuth.accessToken,
        "since" : since,
    }
    authReq.end()
    return

storeDocuments = (json) ->
    if json.list?
        for id, obj of json.list
            obj['_id'] = obj.item_id
            db.addDoc obj, (err, response) -> 
                logger.info "storing document" + obj.item_id
                if err? 
                    logger.error err 
                if response?
                    logger.info response

exports.getItemsSince = (req, res) ->
    callback = (response) ->
        str = ''
        response.on 'data', (chunk) ->
            str += chunk
            return
        response.on 'end', () ->
            res.charset = 'utf-8'
            json = JSON.parse str
            storeDocuments json
            res.json json
            return
        return
    since = if req.query.since? then req.query.since else 0
    getItemsSince callback, since
    return