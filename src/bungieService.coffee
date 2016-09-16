request = require('request')

BUNGIE_API_KEY = 'SECRET'
BUNGIE_API_BASE_URL = 'https://www.bungie.net/platform/destiny'
DEFAULT_PLATFORM = 1 # XBOX Live

ENDPOINTS =
  GET_MEMBERSHIP_ID_BY_DISPLAY_NAME: ""

class BungieService

  constructor: () ->

  getPlayerInfo: (gamerTag, callback) ->
    options =
      timeout: 2000
      url: "#{BUNGIE_API_BASE_URL}/#{DEFAULT_PLATFORM}/Stats/GetMembershipIdByDisplayName/#{gamerTag}"
      json: true
      headers:
        'X-API-Key': BUNGIE_API_KEY

    request options, (error, response, body) ->
      if error or response.statusCode != 200
        return callback "There was an error retreiving the guardian info: #{error or body}"

      memberId = body.Response

      options =
        timeout: 2000
        url: "#{BUNGIE_API_BASE_URL}/#{DEFAULT_PLATFORM}/Account/#{memberId}/Summary"
        json: true
        headers:
          'X-API-Key': BUNGIE_API_KEY

      request options, (error, response, body) ->
        if error or response.statusCode != 200
          return callback "There was an error retreiving the guardian info: #{error or body}"

        callback null, body.Response

  testAPI: (callback) ->
    options =
      timeout: 2000
      url: "#{BUNGIE_API_BASE_URL}/vanguard/grimoire/2/4611686018437163478/"
      json: true
      headers:
        'X-API-Key': BUNGIE_API_KEY

    request options, (error, response, body) ->
      if error or response.statusCode != 200
        return callback "There was an error opening the door: #{error or body}"
      o = ""
#      for k,v of body.Response
#        o +=  k + ":" + v  + ",\n"
      callback null,JSON.stringify(body)


module.exports = BungieService
