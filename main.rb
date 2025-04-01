require "net/http"
require "faye/websocket"
require "eventmachine"
require "json"

EM.run do
  ws = Faye::WebSocket::Client.new("wss://sim3.psim.us/showdown/websocket")

  ws.on :open do |event|
    p [:open]
    ws.send("|/cmd roomlist ,none,ycp3")
  end

  ws.on :message do |event|
    p [:message, event.data]
    if event.data.start_with?("|challstr|")
      challstr = event.data["|challstr|".length..]
      response = Net::HTTP.post_form(URI("https://play.pokemonshowdown.com/api/login"), { challstr: challstr, name: ENV["NAME"], pass: ENV["PASS"] })
      obj = JSON.parse(response.body[1..])
      ws.send("|/trn ycp4,0,#{obj["assertion"]}")
    end
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
end
