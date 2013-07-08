strftime = require('strftime')
querystring = require('querystring')

module.exports = (robot) ->
  robot.respond /!test/, (msg) ->
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
  time = strftime('%Y%m%dT%H:%M:%S')
  signature = sign time, endpoint, params
  query = querystring(params)
  msg.http("http:www.radlibs.info" + endpoint).post(query) (err, res, body) ->
    cb body


auth =
  api_key: process.env.HUBOT_RADLIBS_API_KEY
  user_id: process.env.HUBOT_RADLIBS_API_KEY

sign = (time, endpoint, params) ->
  signature += time
  signature += "\n"
  Object.keys(params).sort.forEach (key) ->
    signature += key + params[key] + "\n"
  signature += endpoint + "\n"
  signature += auth.api_key
  signature
