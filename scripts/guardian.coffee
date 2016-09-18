# Description:
#   Responses to questions about guardians


BungieService = require('../src/bungieService.coffee')

bungieService = new BungieService

module.exports = (robot) ->

  robot.respond /apitest/i, (msg) ->
    bungieService.testAPI (err, res) ->
      if err
        return msg.send err
      msg.send "```#{res}```"

  robot.respond /elo for (.+?) in (.+?)$/i, (msg) ->
    gamerTag = msg.match[1]
    gameMode = msg.match[2]
    bungieService.getElo gamerTag, gameMode, (err, res) ->
      if err
        return msg.send err

      elo = Math.round(res.elo)
      rank = res.rank
      if ( rank == -1)
        rank = "Not yet ranked"
      else
        rank = "ranked \##{rank}"
      ghostResponse = "#{gamerTag}'s elo in #{gameMode} is #{elo} (#{rank})"
      msg.reply ghostResponse

  robot.respond /how many characters does (.+?) have/i, (msg) ->
    gamerTag = msg.match[1]

    bungieService.getPlayerSummary gamerTag, (err, res) ->
      if err
        return msg.send err

      characters = []
      for character in res.data.characters
          simpleCharacter = {}
          simpleCharacter.level = character.characterLevel
          simpleCharacter.lightLevel = character.characterBase.powerLevel
          simpleCharacter.emblem = "https://www.bungie.net#{character.emblemPath}"
          characters.push simpleCharacter

      ghostResponse = "#{gamerTag} has #{characters.length} characters:\n"
      for character in characters
        ghostResponse += "#{character.emblem} Level #{character.level} and #{character.lightLevel} Light\n"

      msg.reply ghostResponse

  robot.respond /what about (.+?)\?*$/i, (msg) ->
      gamerTag = msg.match[1]
      bungieService.getPlayerGuardianGGInfo gamerTag, (err, res) ->
        if err
          return msg.send err

        ghostResponse = "```#{res.gamerTag}:\n"
        for k,v of res.modes
          ghostResponse += "\t#{k}: k/d: #{v.kd}, k/da: #{v.kda}, elo: #{v.elo}, games: #{v.gamesPlayed}\n"
        ghostResponse += "```"
        msg.reply ghostResponse
