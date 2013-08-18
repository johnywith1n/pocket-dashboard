https = require 'https'
fs = require "fs"

REDIRECT_URI = "http://localhost:3000/api/pocketOAuthCallback"
CALLBACK_URI = "/view/synch"
HOST = "getpocket.com"
REQUEST_PATH = "/v3/oauth/request"
AUTHORIZE_PATH = "/v3/oauth/authorize"

exports.consumerKey = fs.readFileSync 'CONSUMER_KEY', 'utf8'

requestToken = (callback) ->
    options = {
        host : HOST,
        path : REQUEST_PATH,
        method : 'POST',
        headers : {
                'Content-Type' : 'application/json; charset=UTF-8',
                'X-Accept' : 'application/json'
        }
    }
    authReq = https.request options, callback
    authReq.write JSON.stringify {
        "consumer_key" : exports.consumerKey,
        "redirect_uri" : REDIRECT_URI
    }
    authReq.end()
    return

exports.requestToken = (req, res) ->
    callback = (response) ->
        str = ''
        response.on 'data', (chunk) ->
            str += chunk
            return
        response.on 'end', () ->
            exports.requestToken = JSON.parse(str).code
            res.redirect 'https://getpocket.com/auth/authorize?request_token=' + exports.requestToken + '&redirect_uri=' + encodeURIComponent REDIRECT_URI
            return
        return
    requestToken callback
    return

pocketOAuthCallback = (callback) ->
    options = {
        host : HOST,
        path : AUTHORIZE_PATH,
        method : 'POST',
        headers : {
            'Content-Type' : 'application/json; charset=UTF-8',
            'X-Accept' : 'application/json'
        }
    }
    
    authReq = https.request options, callback
    authReq.write JSON.stringify {
        "consumer_key" : exports.consumerKey,
        "code" : exports.requestToken
    }
    authReq.end()
    return

exports.pocketOAuthCallback = (req, res) ->
    callback = (response) ->
        str = ''
        response.on 'data', (chunk) ->
            str += chunk
            return
        response.on 'end', () ->
            exports.accessToken = JSON.parse(str).access_token
            res.redirect CALLBACK_URI
            return
        return
    pocketOAuthCallback callback
    return

exports.isAuthorized = (req,res) ->
    res.charset = 'utf-8'
    res.json {
        "status" : "success",
        "payload" : {
            "isAuthorized" : typeof exports.accessToken isnt "undefined" and exports.accessToken isnt null
        }
    }
