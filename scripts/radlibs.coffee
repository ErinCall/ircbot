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
      if response.status == 'ok'
        msg.send 'auth is working fine'
      else
        msg.send response.error
  robot.hear /^!eval (.*)/, (msg) ->
    test_radlib robot, msg.match[1], (response) ->
      if response.status == 'ok'
        msg.send response.radlib
      else
        msg.send response.error
  robot.hear /^!addrad\s+(\w+)\s+(.*)/, (msg) ->
    add_rad robot, msg.match[1], msg.match[2], (response) ->
      if response.status == 'ok'
        msg.send 'Added!'
      else
        msg.send response.error


add_rad = (robot, lib_name, rad, cb) ->
  endpoint = "/lib/rad/new"
  params =
    association_id: auth.association_id
    rad: rad
    lib: lib_name
  api_call robot, endpoint, params, cb


test_radlib = (robot, radlib, cb) ->
  endpoint = "/association/" + auth.association_id + "/test_radlib"
  params = {rad: radlib}
  api_call robot, endpoint, params, cb


test_auth = (robot, cb) ->
  endpoint = "/test_authorization"
  params = {}
  api_call robot, endpoint, params, cb


api_call = (robot, endpoint, params, cb) ->
  time = strftime '%Y%m%dT%H:%M:%S'
  signature = sign time, endpoint, params
  params.time = time
  params.signature = signature
  params.user_id = auth.user_id
  query = querystring.stringify params
  robot.http('http://www.radlibs.info')
    .header('Content-type', 'application/x-www-form-urlencoded')
    .scope endpoint, (cli) ->
      cli.post(query) (error, res, body) ->
        cb JSON.parse(body)

auth =
  api_key: process.env.HUBOT_RADLIBS_API_KEY
  user_id: process.env.HUBOT_RADLIBS_USER_ID
  association_id: process.env.HUBOT_RADLIBS_ASSOCIATION_ID

sign = (time, endpoint, params) ->
  plaintext = time
  plaintext += "\n"
  Object.keys(params).sort().forEach (key) ->
    plaintext += key + ': ' + params[key] + "\n"
  plaintext += endpoint + "\n"
  plaintext += auth.api_key
  sha1 plaintext
