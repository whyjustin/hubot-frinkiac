# Description
#   Searches for a Simpsons quote and generates a screencap using https://www.frinkiac.com
# Commands
#   hubot frinkiac <query> - Display screencap of simpsons scene that matches query

module.exports = (robot) ->
  robot.respond /frinkiac (.*)/i, (res) ->
    query = res.match[1]
    robot.http("https://www.frinkiac.com/api/search?q=#{query}").get() (err, rs, body) ->
      screens = JSON.parse(body)
      screen = screens[0]
      robot.http("https://www.frinkiac.com/api/caption?e=#{screen.Episode}&t=#{screen.Timestamp}").get() (err, rs, body) ->
        captions = JSON.parse(body)
        lines = captions.Subtitles.map((subtitle) -> subtitle.Content).join('%0A')
        res.send "https://www.frinkiac.com/meme/#{screen.Episode}/#{screen.Timestamp}.jpg?lines=#{lines}"