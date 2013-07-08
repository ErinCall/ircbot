# Interacts with www.radlibs.info
#
# !test   - tests that authorization is working

strftime = require('strftime')
querystring = require('querystring')
sha1 = require('sha1')

module.exports = (robot) ->
  robot.respond /test/, (msg) ->
    test_auth (response) ->
      msg.send response
  # robot.respond /!eval (.*)/, (msg) ->
  #   radlib msg, (response) ->
  #     msg.send response

        # url = 'http://httpbin.org/post'
        # data = QS.stringify({'hubot-post': msg.match[1]})

        # msg.http(url)
        #     .post(data) (err, res, body) ->
        #         msg.send body



test_auth = (msg, cb) ->
  endpoint = "/test_authorization"
  params = {}
  console.log("about to generate time")
  time = strftime '%Y%m%dT%H:%M:%S'
  console.log("about to sign")
  signature = sign time, endpoint, params
  console.log("about to generate query string")
  query = querystring.stringify(params)
  console.log("about to POST")
  msg.http("http:www.radlibs.info" + endpoint).post(query) (err, res, body) ->
    cb body


auth =
  api_key: process.env.HUBOT_RADLIBS_API_KEY
  user_id: process.env.HUBOT_RADLIBS_API_KEY

sign = (time, endpoint, params) ->
  plaintext = time
  plaintext += "\n"
  Object.keys(params).sort().forEach (key) ->
    plaintext += key + params[key] + "\n"
  plaintext += endpoint + "\n"
  plaintext += auth.api_key
  sha1 plaintext
