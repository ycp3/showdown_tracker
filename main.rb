require "net/http"
require "faye/websocket"
require "eventmachine"
require "json"
require "discordrb"

bot = Discordrb::Bot.new token: ENV["DISCORD_TOKEN"], intents: :unprivileged
bot.run background: true

# for now hardcoded to one channel because that's all I need it for
channel = bot.servers.values.first.channels.find { |c| c.name == ENV["CHANNEL_NAME"] }
if channel.nil?
  puts "No channel found"
  exit
end

class Score
  def self.file
    File.open("scores", "a+") do |f|
      yield f
    end
  end

  def self.win(player)
    scores = {}
    file do |f|
      content = f.read
      if content.length == 0
        content = "#{ENV["WATCHED_1"]},#{ENV["WATCHED_2"]},0,0"
      end
      content = content.split(",")
      p1 = content[0]
      p2 = content[1]
      p1_score = content[2]
      p2_score = content[3]

      if player == p1
        p1_score = p1_score.to_i + 1
      elsif player == p2
        p2_score = p2_score.to_i + 1
      end

      f.truncate(0)
      f.write("#{p1},#{p2},#{p1_score},#{p2_score}")
      scores = { p1: { name: p1, score: p1_score }, p2: { name: p2, score: p2_score } }
    end

    puts "WIN, #{player}"
    return scores
  end
end

EM.run do
  ws = Faye::WebSocket::Client.new("wss://sim3.psim.us/showdown/websocket")

  ws.on :open do |event|
    ws.send("|/cmd roomlist ,none,#{ENV["WATCHED_1"]}")
    EM.add_periodic_timer(60) do
      ws.send("|/cmd roomlist ,none,#{ENV["WATCHED_1"]}")
    end
  end

  ws.on :message do |event|
    p [:message, event.data]
    if event.data.start_with?("|challstr|")
      challstr = event.data["|challstr|".length..]
      response = Net::HTTP.post_form(URI("https://play.pokemonshowdown.com/api/login"), { challstr: challstr, name: ENV["NAME"], pass: ENV["PASS"] })
      obj = JSON.parse(response.body[1..])
      ws.send("|/trn #{ENV["NAME"]},0,#{obj["assertion"]}")
    end

    if event.data.start_with?("|queryresponse|roomlist|")
      rooms = JSON.parse(event.data["|queryresponse|roomlist|".length..])
      rooms["rooms"].each do |room_id, users|
        if ENV["WATCHED_2"] == users["p1"] || ENV["WATCHED_2"] == users["p2"]
          puts "JOINING"
          ws.send("|/join #{room_id}")
        end
      end
    end

    if event.data.split("|")[-2] == "win"
      scores = Score.win(event.data.split("|")[-1])
      bot.send_message(channel, "#{event.data.split("|")[-1]} won!\n#{scores[:p1][:name]}: #{scores[:p1][:score]} | #{scores[:p2][:name]}: #{scores[:p2][:score]}")
    end
  end

  ws.on :close do |event|
    ws = nil
  end
end

bot.join
