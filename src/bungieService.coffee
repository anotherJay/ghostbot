request = require('request')

BUNGIE_API_KEY = process.env.BUNGIE_API_KEY
# remove any newlines at the end of the API KEY
BUNGIE_API_KEY.replace(/(\n|\r)+$/, '')
BUNGIE_API_BASE_URL = 'https://www.bungie.net/platform/destiny'
GUARDIANGG_API_BASE_URL = 'https://api.guardian.gg'
DEFAULT_PLATFORM = 1 # XBOX Live

GAME_MODES =
        "crimson doubles" : 523
        "trials of osiris": 14
        "too": 14
        "trials": 14
        "iron banner": 19
        "ib": 19
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

  getPlayerGuardianGGInfo: (gamerTag, callback) ->

    this.searchDestinyPlayer gamerTag, (err, res) =>
      if err
        return callback err

      memberId = res.memberId
      realGamerTag = res.gamerTag

      options =
        timeout: 2000
        url: "#{GUARDIANGG_API_BASE_URL}/v2/players/#{memberId}"
        json: true

      console.log "Calling endpoint #{options.url}"
      request options, (error, response, body) =>
        if error or response.statusCode != 200
          return callback "There was an error retreiving the guardian's elo: #{error or body}"

        player =
          gamerTag: body.data.name
          modes: {}

        for k, v of body.data.modes
          modeName = this.getGameModeById k
          if( !modeName )
            console.log "Couldn't find modeName for #{k}"
          else
            v.modeName = modeName
            v.kd = Math.round((v.kills/v.deaths) * 100) / 100
            v.kda = Math.round(((v.kills + v.assists) / v.deaths) * 100) / 100
            v.elo = Math.round(v.elo)
            player.modes[modeName] = v

        callback null, player

  getElo: (gamerTag, gameMode, callback) ->
    modeId = this.getGameMode gameMode.toLowerCase()
    if !modeId
      return callback "The game mode #{gameMode} is not valid"

    this.searchDestinyPlayer gamerTag, (err, res) ->
      if err
        return callback err

      memberId = res.memberId
      realGamerTag = res.gamerTag

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

  getGameModeById: (modeId) ->
    for k,v of GAME_MODES
      return k if parseInt(v) == parseInt(modeId)
    return null

  searchDestinyPlayer: (gamerTag, callback) ->
    options =
      timeout: 2000
      url: "#{BUNGIE_API_BASE_URL}/SearchDestinyPlayer/#{DEFAULT_PLATFORM}/#{gamerTag}"
      json: true
      headers:
        'X-API-Key': BUNGIE_API_KEY
    player = null

    console.log "Calling endpoint #{options.url}"
    request options, (error, response, body) ->
      if error or response.statusCode != 200 or body.Response.length == 0
        return callback "There was an error retreiving the guardian info for #{gamerTag}: #{error or body}"

      player =
        memberId: body.Response[0].membershipId
        gamerTag: body.Response[0].displayName

      callback null, player


  getPlayerSummary: (gamerTag, callback) ->
    this.searchDestinyPlayer gamerTag, (err, res) ->
      if err
        return callback err

      memberId = res.memberId

      options =
        timeout: 2000
        url: "#{BUNGIE_API_BASE_URL}/#{DEFAULT_PLATFORM}/Account/#{memberId}/Summary"
        json: true
        headers:
          'X-API-Key': BUNGIE_API_KEY

      console.log "Calling endpoint #{options.url}"
      request options, (error, response, body) ->
        if error or response.statusCode != 200
          return callback "There was an error retreiving the guardian info: #{error or body}"

        callback null, body.Response



  testAPI: (callback) ->
    options =
      timeout: 2000
      url: "#{BUNGIE_API_BASE_URL}/manifest"
      json: true
      headers:
        'X-API-Key': BUNGIE_API_KEY

    console.log "Calling endpoint #{options.url}"
    request options, (error, response, body) ->
      if error or response.statusCode != 200
        return callback "There was an error opening the door: #{error or body}"
      o = ""
#      for k,v of body.Response
#        o +=  k + ":" + v  + ",\n"
      callback null,JSON.stringify(body)


module.exports = BungieService
