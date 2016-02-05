# Description
#   Searches for a Simpsons quote and generates a screencap using https://www.frinkiac.com
# Commands
#   hubot frinkiac <query> - Display screencap of simpsons scene that matches query

format = (captions) ->
  lines = captions.Subtitles.map((subtitle) -> subtitle.Content)

  # If any line is greater than 25 characters, reformat
  if (lines.some((line) -> line.length > 25))
    words = lines.join(' ').split(' ')
    lines = []
    line = ''
    words.forEach (word) ->
      # Shoddy attempt to break lines at sentence end
      cleanBreak = line.length + word.length >= 15 and ['?', '!', '.', ']', ')'].some((punctuation) -> word.indexOf(punctuation, this.length - punctuation.length) != -1)
      if (cleanBreak)
        line += "#{word}"
        lines.push(encodeURIComponent(line.trim()))
        line = ''
      else if (line.length + word.length >= 25)
        lines.push(encodeURIComponent(line.trim()))
        line = "#{word} "
      else
        line += "#{word} "
    if (line.length > 0)
      lines.push(encodeURIComponent(line.trim()))
  
  return lines.join('%0A')

module.exports = (robot) ->
  robot.respond /frinkiac (.*)/i, (res) ->
    query = res.match[1]
    robot.http("https://www.frinkiac.com/api/search?q=#{query}").get() (err, rs, body) ->
      screens = JSON.parse(body)
      screen = screens[0]
      robot.http("https://www.frinkiac.com/api/caption?e=#{screen.Episode}&t=#{screen.Timestamp}").get() (err, rs, body) ->
        captions = JSON.parse(body)
        lines = format captions
        res.send "https://www.frinkiac.com/meme/#{screen.Episode}/#{screen.Timestamp}.jpg?lines=#{lines}"