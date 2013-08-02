https = require 'https'
pocketOAuth = require('./pocketOAuth.js')

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

exports.getItemsSince = (req, res) ->
    callback = (response) ->
        str = ''
        response.on 'data', (chunk) ->
            str += chunk
            return
        response.on 'end', () ->
        	res.charset = 'utf-8'
        	res.json JSON.parse str
        	return
        return
    since = if req.query.since? then req.query.since else 0
    getItemsSince callback, since
    return