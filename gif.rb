require "rmagick"
require "json"
require "net/http"
require "open-uri"

def get_sprite(name)
  return "sprites/#{name}.png" if File.exist?("sprites/#{name}.png")
  url = URI("https://pokeapi.co/api/v2/pokemon-species/#{name}")
  response = Net::HTTP.get(url)
  url = URI(JSON.parse(response)["varieties"].first["pokemon"]["url"])
  response = Net::HTTP.get(url)
  data = JSON.parse(response)
  sprite_url = data["sprites"]["front_default"]
  sprite_image = URI.open(sprite_url)

  File.open("sprites/#{name}.png", "wb") do |file|
    file.write(sprite_image.read)
  end

  "sprites/#{name}.png"
end

def silence_crab(winner, loser)
  crab = Magick::Image.read("images/crab.png").first
  winner_image = Magick::Image.read(get_sprite(winner)).first
  loser_image = Magick::Image.read(get_sprite(loser)).first

  loser_image.background_color = "transparent"
  crab.composite!(winner_image.resize(300, 300), 260, 50, Magick::OverCompositeOp)
  crab.composite!(loser_image.resize(300, 300).rotate(45).flop, -120, 180, Magick::OverCompositeOp)

  loser_text = Magick::Draw.new
  loser_text.font = "Helvetica"
  loser_text.fill = "white"
  loser_text.pointsize = 72
  loser_text.gravity = Magick::NorthWestGravity
  loser_text.annotate(crab, 0, 0, 50, 80, loser)

  crab.write("silenced_crab.png")
end

def slap(slapper, slapped)
  gif = Magick::ImageList.new("images/slap.gif")
  slapper_image = Magick::Image.read(get_sprite(slapper)).first
  slapped_image = Magick::Image.read(get_sprite(slapped)).first
  slapper_image.background_color = "transparent"
  slapped_image.background_color = "transparent"
  gif[0].composite!(slapped_image.resize(300, 300).flop, 280, 50, Magick::OverCompositeOp)
  gif[1].composite!(slapper_image.resize(200, 200).flop, -100, 100, Magick::OverCompositeOp)
  gif[1].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[2].composite!(slapper_image.resize(200, 200).flop, -50, 100, Magick::OverCompositeOp)
  gif[2].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[3].composite!(slapper_image.resize(200, 200).flop, 0, 100, Magick::OverCompositeOp)
  gif[3].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[4].composite!(slapper_image.resize(200, 200).flop, 40, 100, Magick::OverCompositeOp)
  gif[4].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[5].composite!(slapper_image.resize(200, 200).flop, 80, 100, Magick::OverCompositeOp)
  gif[5].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[6].composite!(slapper_image.resize(200, 200).flop, 130, 100, Magick::OverCompositeOp)
  gif[6].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[7].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[7].composite!(slapper_image.resize(200, 200).flop, 170, 100, Magick::OverCompositeOp)
  gif[8].composite!(slapped_image.resize(300, 300), 250, 50, Magick::OverCompositeOp)
  gif[8].composite!(slapper_image.resize(200, 200).flop, 200, 100, Magick::OverCompositeOp)
  (9..27).each do |i|
    gif[i].composite!(slapped_image.resize(1000, 1000), 0, -200, Magick::OverCompositeOp)
  end
  gif[28].composite!(slapped_image.resize(600, 600), 150, -50, Magick::OverCompositeOp)
  gif[28].composite!(slapper_image.resize(300, 300).flop, -100, 50, Magick::OverCompositeOp)
  gif[29].composite!(slapped_image.resize(600, 600), 150, -50, Magick::OverCompositeOp)
  gif[29].composite!(slapper_image.resize(300, 300).flop, 120, 50, Magick::OverCompositeOp)
  gif[30].composite!(slapped_image.resize(600, 600), 150, -50, Magick::OverCompositeOp)
  gif[30].composite!(slapper_image.resize(300, 300).flop, 120, 50, Magick::OverCompositeOp)
  gif[31].composite!(slapped_image.resize(600, 600), 150, -50, Magick::OverCompositeOp)
  gif[31].composite!(slapper_image.resize(300, 300).flop, 120, 50, Magick::OverCompositeOp)
  gif[32].composite!(slapped_image.resize(600, 600), 150, -50, Magick::OverCompositeOp)
  gif[32].composite!(slapper_image.resize(300, 300).flop, 120, 50, Magick::OverCompositeOp)
  gif[33].composite!(slapped_image.resize(600, 600).rotate(30), 150, -50, Magick::OverCompositeOp)
  gif[33].composite!(slapper_image.resize(300, 300).flop.rotate(15), 140, 0, Magick::OverCompositeOp)
  (34..41).each do |i|
    gif[i].composite!(slapped_image.resize(600, 600).rotate(30), 150, -50, Magick::OverCompositeOp)
    gif[i].composite!(slapper_image.resize(300, 300).flop.rotate(15), 40, 0, Magick::OverCompositeOp)
  end
  gif[42].composite!(slapped_image.resize(600, 600), 200, -150, Magick::OverCompositeOp)
  gif[42].composite!(slapper_image.resize(300, 300).flop, -130, 60, Magick::OverCompositeOp)
  gif[43].composite!(slapped_image.resize(600, 600), 200, -150, Magick::OverCompositeOp)
  gif[43].composite!(slapper_image.resize(300, 300).flop, -20, 60, Magick::OverCompositeOp)
  gif[44].composite!(slapped_image.resize(600, 600), 200, -150, Magick::OverCompositeOp)
  gif[44].composite!(slapper_image.resize(300, 300).flop, 80, 60, Magick::OverCompositeOp)
  gif[45].composite!(slapped_image.resize(600, 600), 200, -150, Magick::OverCompositeOp)
  gif[45].composite!(slapper_image.resize(300, 300).flop, 150, 60, Magick::OverCompositeOp)
  gif[46].composite!(slapped_image.resize(600, 600), 250, -150, Magick::OverCompositeOp)
  gif[46].composite!(slapper_image.resize(300, 300).flop, 200, 60, Magick::OverCompositeOp)
  gif[47].composite!(slapped_image.resize(600, 600), 250, -150, Magick::OverCompositeOp)
  gif[47].composite!(slapper_image.resize(300, 300).flop, 200, 60, Magick::OverCompositeOp)
  gif[48].composite!(slapped_image.resize(600, 600), 250, -170, Magick::OverCompositeOp)
  gif[48].composite!(slapper_image.resize(300, 300).flop, 200, 60, Magick::OverCompositeOp)
  gif[49].composite!(slapped_image.resize(600, 600), 150, -275, Magick::OverCompositeOp)
  gif[49].composite!(slapper_image.resize(300, 300).flop.rotate(-15), 120, 20, Magick::OverCompositeOp)
  gif[50].composite!(slapped_image.resize(600, 600).rotate(-45), -350, -450, Magick::OverCompositeOp)
  gif[50].composite!(slapper_image.resize(300, 300).flop.rotate(-45), 10, -20, Magick::OverCompositeOp)
  gif[51].composite!(slapped_image.resize(600, 600).rotate(-45), -350, -400, Magick::OverCompositeOp)
  gif[51].composite!(slapper_image.resize(300, 300).flop.rotate(-55), 10, -20, Magick::OverCompositeOp)
  (52..57).each do |i|
    gif[i].composite!(slapped_image.resize(600, 600).rotate(-55), -350, -400, Magick::OverCompositeOp)
    gif[i].composite!(slapper_image.resize(300, 300).flop.rotate(-65), 10, -20, Magick::OverCompositeOp)
  end
  gif[58].composite!(slapped_image.resize(600, 600), 0, -400, Magick::OverCompositeOp)
  gif[58].composite!(slapper_image.resize(300, 300).flop, 120, 20, Magick::OverCompositeOp)
  gif[59].composite!(slapped_image.resize(600, 600).rotate(45), 100, -450, Magick::OverCompositeOp)
  gif[59].composite!(slapper_image.resize(300, 300).flop.rotate(45), 120, -100, Magick::OverCompositeOp)
  gif[60].composite!(slapped_image.resize(600, 600).rotate(60), 100, -350, Magick::OverCompositeOp)
  gif[60].composite!(slapper_image.resize(300, 300).flop.rotate(180), 170, -20, Magick::OverCompositeOp)
  gif[61].composite!(slapped_image.resize(500, 500).rotate(-60), 100, -300, Magick::OverCompositeOp)
  gif[61].composite!(slapper_image.resize(300, 300).flop.rotate(-70), 50, -60, Magick::OverCompositeOp)
  gif[62].composite!(slapped_image.resize(400, 400).rotate(140), 150, -150, Magick::OverCompositeOp)
  gif[62].composite!(slapper_image.resize(300, 300).flop.rotate(90), 80, -20, Magick::OverCompositeOp)
  gif[63].composite!(slapped_image.resize(300, 300).rotate(-90), 270, -60, Magick::OverCompositeOp)
  gif[63].composite!(slapper_image.resize(300, 300).flop.rotate(-110), 40, -40, Magick::OverCompositeOp)
  gif[64].composite!(slapped_image.resize(250, 250).rotate(80), 350, -40, Magick::OverCompositeOp)
  gif[64].composite!(slapper_image.resize(300, 300).flop.rotate(80), 40, -40, Magick::OverCompositeOp)
  gif[65].composite!(slapped_image.resize(175, 175).rotate(200), 350, -40, Magick::OverCompositeOp)
  gif[65].composite!(slapper_image.resize(300, 300).flop.rotate(180), 40, 40, Magick::OverCompositeOp)
  gif[66].composite!(slapped_image.resize(125, 125).rotate(-45), 400, 0, Magick::OverCompositeOp)
  gif[66].composite!(slapper_image.resize(300, 300).flop.rotate(-70), 0, 0, Magick::OverCompositeOp)
  gif[67].composite!(slapped_image.resize(100, 100).rotate(80), 450, 50, Magick::OverCompositeOp)
  gif[67].composite!(slapper_image.resize(300, 300).flop, 50, 0, Magick::OverCompositeOp)
  gif[68].composite!(slapped_image.resize(75, 75).rotate(180), 500, 50, Magick::OverCompositeOp)
  gif[68].composite!(slapper_image.resize(300, 300).flop, 50, 0, Magick::OverCompositeOp)
  gif[69].composite!(slapped_image.resize(50, 50).rotate(-110), 520, 60, Magick::OverCompositeOp)
  gif[69].composite!(slapper_image.resize(300, 300).flop, 50, 0, Magick::OverCompositeOp)
  gif[70].composite!(slapped_image.resize(25, 25).rotate(-70), 540, 75, Magick::OverCompositeOp)
  gif[70].composite!(slapper_image.resize(300, 300).flop, 50, 50, Magick::OverCompositeOp)
  gif[71].composite!(slapped_image.resize(25, 25).rotate(90), 550, 78, Magick::OverCompositeOp)
  gif[71].composite!(slapper_image.resize(300, 300).flop, 60, 80, Magick::OverCompositeOp)
  gif[72].composite!(slapped_image.resize(25, 25).rotate(-120), 550, 78, Magick::OverCompositeOp)
  gif[72].composite!(slapper_image.resize(300, 300).flop, 60, 80, Magick::OverCompositeOp)
  gif[73].composite!(slapped_image.resize(10, 10).rotate(-120), 566, 84, Magick::OverCompositeOp)
  gif[73].composite!(slapper_image.resize(300, 300).flop, 60, 80, Magick::OverCompositeOp)
  gif[74].composite!(slapped_image.resize(10, 10).rotate(-120), 566, 84, Magick::OverCompositeOp)
  gif[74].composite!(slapper_image.resize(300, 300).flop, 60, 80, Magick::OverCompositeOp)
  gif[75].composite!(slapper_image.resize(300, 300).flop, 20, 40, Magick::OverCompositeOp)
  gif[76].composite!(slapper_image.resize(300, 300).flop, 80, 60, Magick::OverCompositeOp)
  gif[77].composite!(slapper_image.resize(300, 300).flop, 0, 100, Magick::OverCompositeOp)
  gif[78].composite!(slapper_image.resize(300, 300).flop, 60, 80, Magick::OverCompositeOp)
  gif[79].composite!(slapper_image.resize(300, 300).flop, -20, 20, Magick::OverCompositeOp)
  gif[80].composite!(slapper_image.resize(300, 300).flop, 40, 0, Magick::OverCompositeOp)
  gif[81].composite!(slapper_image.resize(300, 300).flop, -20, 60, Magick::OverCompositeOp)
  gif[82].composite!(slapper_image.resize(300, 300).flop, 40, 60, Magick::OverCompositeOp)
  gif[83].composite!(slapper_image.resize(300, 300).flop, -20, 40, Magick::OverCompositeOp)
  gif[84].composite!(slapper_image.resize(300, 300).flop, 40, 20, Magick::OverCompositeOp)
  gif[85].composite!(slapper_image.resize(300, 300).flop, -20, 60, Magick::OverCompositeOp)
  gif[86].composite!(slapper_image.resize(300, 300).flop, 40, 40, Magick::OverCompositeOp)
  gif[87].composite!(slapper_image.resize(300, 300).flop, -20, 40, Magick::OverCompositeOp)
  gif[88].composite!(slapper_image.resize(300, 300).flop, 60, 0, Magick::OverCompositeOp)
  gif[89].composite!(slapper_image.resize(300, 300).flop, -20, 60, Magick::OverCompositeOp)
  gif[90].composite!(slapper_image.resize(300, 300).flop, 60, 20, Magick::OverCompositeOp)
  gif[91].composite!(slapper_image.resize(300, 300).flop, -20, 0, Magick::OverCompositeOp)
  gif[92].composite!(slapper_image.resize(300, 300).flop, 60, 40, Magick::OverCompositeOp)
  gif[93].composite!(slapper_image.resize(300, 300).flop, -20, 40, Magick::OverCompositeOp)
  gif[94].composite!(slapper_image.resize(300, 300).flop, 60, 40, Magick::OverCompositeOp)
  gif[95].composite!(slapper_image.resize(300, 300).flop, 20, 40, Magick::OverCompositeOp)
  gif[96].composite!(slapper_image.resize(300, 300).flop, 60, 60, Magick::OverCompositeOp)
  gif[97].composite!(slapper_image.resize(300, 300).flop, -20, 80, Magick::OverCompositeOp)
  gif[98].composite!(slapper_image.resize(300, 300).flop, 40, 60, Magick::OverCompositeOp)
  opt_gif = gif.optimize_layers(Magick::OptimizeLayer)
  opt_gif.write("slap.gif")
end
