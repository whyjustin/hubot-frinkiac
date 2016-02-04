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
        lines = ''
        captions = JSON.parse(body)
        captions.Subtitles.forEach (caption) ->
          lines += caption.Content.replace(/[ ]/gi, '+') + '%0A'
        lines = lines.substring(0, lines.length - 3)
        res.send "https://www.frinkiac.com/meme/#{screen.Episode}/#{screen.Timestamp}.jpg?lines=#{lines}"