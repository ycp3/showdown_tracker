require "./gif"

class Battle
  attr_accessor :p1, :p2, :p1_mon, :p2_mon, :p1_hp, :p2_hp, :slapped, :missed

  def initialize(p1, p2, p1_mon, p2_mon, p1_hp, p2_hp)
    @p1 = p1
    @p2 = p2
    @p1_mon = p1_mon
    @p2_mon = p2_mon
    @p1_hp = p1_hp
    @p2_hp = p2_hp
    @slapped = []
    @missed = []
    p "BATTLE STARTED"
    p "P1: #{@p1_mon} - #{@p1_hp}"
    p "P2: #{@p2_mon} - #{@p2_hp}"
  end

  def swap_p1(mon, hp)
    @p1_mon = mon
    @p1_hp = hp
    p "P1 SWAP #{mon} #{hp}"
  end

  def swap_p2(mon, hp)
    @p2_mon = mon
    @p2_hp = hp
    p "P2 SWAP #{mon} #{hp}"
  end
end

class BattleManager
  attr_accessor :battles

  def initialize(bot, channel)
    @bot = bot
    @channel = channel
    @battles = {}
    @memes = true
  end

  def event(data, memes)
    @memes = memes
    data = data.split("\n")
    battle = data[0]
    if data[1].start_with?("|init|")
      p1_mon = data.reverse.find { |line| line.start_with?("|switch|p1") }.split(" ")[1..].join(" ").split("|")[0]
      p2_mon = data.reverse.find { |line| line.start_with?("|switch|p2") }.split(" ")[1..].join(" ").split("|")[0]
      @battles[battle] = Battle.new(
        data.find { |line| line.start_with?("|player|p1|") }.split("|")[-2],
        data.find { |line| line.start_with?("|player|p2|") }.split("|")[-2],
        p1_mon,
        p2_mon,
        (data.reverse.find { |line| line.match?(/\|-(damage|heal)\|p1a: #{p1_mon}\|/) } || "100/100").split("/")[0].gsub("|", " ")[-3..].to_i,
        (data.reverse.find { |line| line.match?(/\|-(damage|heal)\|p2a: #{p2_mon}\|/) } || "100/100").split("/")[0].gsub("|", " ")[-3..].to_i
      )
      return
    end

    data.each_with_index do |line, index|
      if line.start_with?("|-miss|p1")
        b = @battles[battle]
        if b.missed.include?([:p1, b.p1_mon, b.p2_mon])
          weave(b.p1_mon, b.p2_mon)
          b.missed.delete([:p1, b.p1_mon, b.p2_mon])
          @bot.send_file(@channel, File.open("weave.gif", "r")) if @memes
        else
          @battles[battle].missed << [:p1, b.p1_mon, b.p2_mon]
        end
      elsif line.start_with?("|-miss|p2")
        b = @battles[battle]
        if b.missed.include?([:p2, b.p2_mon, b.p1_mon])
          weave(b.p2_mon, b.p1_mon)
          b.missed.delete([:p2, b.p2_mon, b.p1_mon])
          @bot.send_file(@channel, File.open("weave.gif", "r")) if @memes
        else
          @battles[battle].missed << [:p2, b.p2_mon, b.p1_mon]
        end
      elsif line.start_with?("|-damage|p1") && line.split("/")[0].gsub("|", " ")[-3..].to_i > 0
        @battles[battle].p1_hp = line.split("/")[0].gsub("|", " ")[-3..].to_i
      elsif line.start_with?("|-damage|p2") && line.split("/")[0].gsub("|", " ")[-3..].to_i > 0
        @battles[battle].p2_hp = line.split("/")[0].gsub("|", " ")[-3..].to_i
      elsif line.start_with?("|switch|p1")
        @battles[battle].swap_p1(
          line.split(" ")[1..].join(" ").split("|")[0],
          line.split("/")[0].gsub("|", " ")[-3..].to_i
        )
      elsif line.start_with?("|switch|p2")
        @battles[battle].swap_p2(
          line.split(" ")[1..].join(" ").split("|")[0],
          line.split("/")[0].gsub("|", " ")[-3..].to_i
        )
      elsif line.end_with?("|0 fnt|[from] psn")
        if line.start_with?("|-damage|p1")
          suds(@battles[battle].p1_mon)
        elsif line.start_with?("|-damage|p2")
          suds(@battles[battle].p2_mon)
        end
        @bot.send_file(@channel, File.open("suds.gif", "r")) if @memes
      elsif line.start_with?("|faint|p1") && index >= 2 && data[index - 2].start_with?("|-crit|p1")
        b = @battles[battle]
        nine(b.p2_mon, b.p1_mon)
        @bot.send_file(@channel, File.open("9.gif", "r")) if @memes
      elsif line.start_with?("|faint|p2") && index >= 2 && data[index - 2].start_with?("|-crit|p2")
        b = @battles[battle]
        nine(b.p1_mon, b.p2_mon)
        @bot.send_file(@channel, File.open("9.gif", "r")) if @memes
      elsif line.start_with?("|faint|p1") && @battles[battle].slapped.include?([:p1, @battles[battle].p1_mon])
        b = @battles[battle]
        silence_crab(b.p2_mon, b.p1_mon)
        @bot.send_file(@channel, File.open("silenced_crab.png", "r")) if @memes
      elsif line.start_with?("|faint|p2") && @battles[battle].slapped.include?([:p2, @battles[battle].p2_mon])
        b = @battles[battle]
        silence_crab(b.p1_mon, b.p2_mon)
        @bot.send_file(@channel, File.open("silenced_crab.png", "r")) if @memes
      elsif line.start_with?("|faint|p1") && @battles[battle].p1_hp == 100
        b = @battles[battle]
        slap(b.p2_mon, b.p1_mon)
        @battles[battle].slapped.push([:p2, b.p2_mon])
        @bot.send_file(@channel, File.open("slap.gif", "r")) if @memes
      elsif line.start_with?("|faint|p2") && @battles[battle].p2_hp == 100
        b = @battles[battle]
        slap(b.p1_mon, b.p2_mon)
        @battles[battle].slapped.push([:p1, b.p1_mon])
        @bot.send_file(@channel, File.open("slap.gif", "r")) if @memes
      end
    end
  end
end
