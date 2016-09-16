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

  robot.respond /how many characters does (.+?) have/i, (msg) ->
    gamerTag = msg.match[1]

    bungieService.getPlayerInfo gamerTag, (err, res) ->
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
