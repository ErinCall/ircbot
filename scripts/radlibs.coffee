# Interacts with www.radlibs.info
#
# test   - tests that authorization is working
# !eval  - evals the given param

strftime = require('strftime')
querystring = require('querystring')
sha1 = require('sha1')

module.exports = (robot) ->
  robot.respond /test/, (msg) ->
    test_auth robot, (response) ->
      msg.send response
  robot.hear /!eval (.*)/, (msg) ->
    test_radlib robot, msg.match[1], (response) ->
      msg.send response
      body = JSON.parse response
      msg.send body.radlib


test_radlib = (robot, radlib, cb) ->
  endpoint = "/association/1/test_radlib"
  params = {rad: radlib}
  time = strftime '%Y%m%dT%H:%M:%S'
  signature = sign time, endpoint, params
  params.time = time
  params.signature = signature
  params.user_id = auth.user_id
  query = querystring.stringify(params)
  robot.http("http://www.radlibs.info")
    .header('Content-type', 'application/x-www-form-urlencoded')
    .scope endpoint, (cli) ->
      cli.post(query) (error, res,body) ->
        cb body


test_auth = (robot, cb) ->
  endpoint = "/test_authorization"
  params = {}
  time = strftime '%Y%m%dT%H:%M:%S'
  signature = sign time, endpoint, params
  params.time = time
  params.signature = signature
  params.user_id = auth.user_id
  query = querystring.stringify(params)
  console.log(params)
  robot.http("http://www.radlibs.info")
    .header('Content-type', 'application/x-www-form-urlencoded')
    .scope endpoint, (cli) ->
      cli.post(query) (error, res,body) ->
        cb body



auth =
  api_key: process.env.HUBOT_RADLIBS_API_KEY
  user_id: process.env.HUBOT_RADLIBS_USER_ID

sign = (time, endpoint, params) ->
  plaintext = time
  plaintext += "\n"
  Object.keys(params).sort().forEach (key) ->
    plaintext += key + ': ' + params[key] + "\n"
  plaintext += endpoint + "\n"
  plaintext += auth.api_key
  sha1 plaintext
