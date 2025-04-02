require "net/http"
require "faye/websocket"
require "eventmachine"
require "json"
require "discordrb"

def init_file(f)
  f.truncate(0)
  f.write("#{ENV["WATCHED_1"]},#{ENV["WATCHED_2"]},0,0\nn\n")
  f.rewind
end

def win(player)
  scores = {}
  File.open("scores", "a+") do |f|
    init_file(f) if f.size == 0
    content = f.readline
    first_to = f.readline

    content = content.split(",")
    p1 = content[0]
    p2 = content[1]
    p1_score = content[2].to_i
    p2_score = content[3].to_i

    first_to = first_to.split(",")
    first_to_score = first_to[1].to_i
    first_to_p1_score = first_to[2].to_i
    first_to_p2_score = first_to[3].to_i

    if player == p1
      p1_score += 1
      first_to_p1_score += 1
    elsif player == p2
      p2_score += 1
      first_to_p2_score += 1
    end

    scores = {
      p1: { name: p1, score: p1_score },
      p2: { name: p2, score: p2_score },
      first_to: {
        in_progress: first_to[0] == "y",
        winner: nil,
        score: first_to_score,
        p1_score: first_to_p1_score,
        p2_score: first_to_p2_score
      }
    }

    if first_to_p1_score >= first_to_score
      first_to = "n"
      scores[:first_to][:winner] = p1
    elsif first_to_p2_score >= first_to_score
      first_to = "n"
      scores[:first_to][:winner] = p2
    else
      first_to = "y,#{first_to_score},#{first_to_p1_score},#{first_to_p2_score}"
    end

    f.truncate(0)
    f.write("#{p1},#{p2},#{p1_score},#{p2_score}\n#{first_to}\n")
  end

  puts "WIN, #{player}"
  return scores
end

def start_first_to(n)
  File.open("scores", "a+") do |f|
    init_file(f) if f.size == 0
    line_1 = f.readline
    first_to = f.readline
    return false if first_to[0] == "y"
    f.truncate(0)
    f.write("#{line_1}y,#{n},0,0\n")
  end

  true
end

def cancel_first_to
  File.open("scores", "a+") do |f|
    init_file(f) if f.size == 0
    line_1 = f.readline
    first_to = f.readline
    return false if first_to[0] == "n"
    f.truncate(0)
    f.write("#{line_1}n\n")
  end

  true
end

def format_message(winner, scores)
  msg = "**#{winner} won!**"

  if scores[:first_to][:in_progress]
    msg += "\n\nCurrent game: First to #{scores[:first_to][:score]}"
    msg += "\n#{scores[:p1][:name]} #{scores[:first_to][:p1_score]} | #{scores[:first_to][:p2_score]} #{scores[:p2][:name]}"
    if scores[:first_to][:winner]
      msg += "\n**#{scores[:first_to][:winner]} wins!**"
    end
  end

  msg += "\n\nOverall:\n#{scores[:p1][:name]} #{scores[:p1][:score]} | #{scores[:p2][:score]} #{scores[:p2][:name]}"
end

bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_TOKEN"], intents: :unprivileged, prefix: "!"

bot.command :bestof do |event, *args|
  n = args[0].to_i
  return "number must be odd" unless n.odd?
  return "number must be positive" unless n > 0
  return "bestof already in progress" unless start_first_to(n / 2 + 1)
  "Started best of #{n}! First to #{n / 2 + 1} wins!"
end

bot.command :firstto do |event, *args|
  n = args[0].to_i
  return "number must be positive" unless n > 0
  return "firstto already in progress" unless start_first_to(n)
  "Started first to #{n}!"
end

bot.command :cancel do |event|
  return "nothing in progress" unless cancel_first_to
  "Cancelled game!"
end

bot.run background: true

# for now hardcoded to one channel because that's all I need it for
channel = bot.servers[ENV["SERVER_ID"].to_i].channels.find { |c| c.name == ENV["CHANNEL_NAME"] }
if channel.nil?
  puts "No channel found"
  exit
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
      winner = event.data.split("|")[-1]
      scores = win(winner)
      bot.send_message(channel, format_message(winner, scores))
    end
  end

  ws.on :close do |event|
    ws = nil
    p [:close, event]
  end
end

bot.join
