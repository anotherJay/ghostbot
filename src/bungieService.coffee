request = require('request')

BUNGIE_API_KEY = process.env.BUNGIE_API_KEY
# remove any newlines at the end of the API KEY
BUNGIE_API_KEY.replace(/(\n|\r)+$/, '')
BUNGIE_API_BASE_URL = 'https://www.bungie.net/platform/destiny'
GUARDIANGG_API_BASE_URL = 'https://api.guardian.gg'
DEFAULT_PLATFORM = 1 # XBOX Live

GAME_MODES =
        "crimson doubles" : 523
        "too": 14
        "trials": 14
        "trials of osiris": 14
        "ib": 19
        "iron banner": 19
        "control": 10
        "clash": 12
        "rift": 24
        "rumble": 13
        "elimination": 23
        "salvage": 11
        "doubles": 15
        "zone control": 28
        "srl": 29
        "skirmish": 9

class BungieService

  constructor: () ->

  getElo: (gamerTag, gameMode, callback) ->
    modeId = this.getGameMode gameMode.toLowerCase()
    if !modeId
      return callback "The game mode #{gameMode} is not valid"

    options =
      timeout: 2000
      url: "#{BUNGIE_API_BASE_URL}/#{DEFAULT_PLATFORM}/Stats/GetMembershipIdByDisplayName/#{gamerTag}"
      json: true
      headers:
        'X-API-Key': BUNGIE_API_KEY


    console.log "Calling endpoint #{options.url}"
    request options, (error, response, body) ->
      if error or response.statusCode != 200
        return callback "There was an error retreiving the guardian's member id: #{error or body}"

      memberId = body.Response

      options =
        timeout: 2000
        url: "#{GUARDIANGG_API_BASE_URL}/elo/#{memberId}"
        json: true

      console.log "Calling endpoint #{options.url}"
      request options, (error, response, body) ->
        if error or response.statusCode != 200
          return callback "There was an error retreiving the guardian's elo: #{error or body}"

        find = (i for i in body when i.mode is modeId)[0]
        callback null, find

  getGameMode: (modeName) ->
    return GAME_MODES[modeName]

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

    console.log options

    request options, (error, response, body) ->
      if error or response.statusCode != 200
        return callback "There was an error opening the door: #{error or body}"
      o = ""
#      for k,v of body.Response
#        o +=  k + ":" + v  + ",\n"
      callback null,JSON.stringify(body)


module.exports = BungieService
