require 'dotenv'
require 'hashie'
require 'net/http'
require 'json'
require 'time'

class Array
  def splatoon_time_convert(st)
    case st
    when nil
      self[0..2]
    else
      self.drop_while { |b| Time.parse(b["start"]).hour != st.to_i }[0..2]
    end
  end
end

class SplatoonStageInfoExtractor
  def fetch_coop_info!
    coop_uri = URI("https://spla2.yuu26.com/coop/schedule")
    coop_info = JSON.parse(Net::HTTP.get_response(coop_uri).body.to_s)
    @coop_info = Hashie::Mash.new(coop_info)
  end

  def get_coop_info_detail
    coop_start = Time.parse(@coop_info.result[0].start)
    coop_end = Time.parse(@coop_info.result[0].end)
    coop_stage = @coop_info.result[0].stage
    coop_weapons = @coop_info.result[0].weapons

    <<~INFO
    [鮭]
    時間: #{coop_start.month}月#{coop_start.day}日 #{coop_start.hour}:00 ~ #{coop_end.month}月#{coop_end.day}日 #{coop_end.hour}時
    #{coop_stage["name"]}
    #{coop_weapons.map { |w| w["name"] }.join ', '}
    INFO
  end

  def fetch_battle_info!
    battle_uri = URI("https://spla2.yuu26.com/schedule")
    battle_info = JSON.parse(Net::HTTP.get_response(battle_uri).body.to_s)
    @battle_info = Hashie::Mash.new(battle_info)
  end

  def get_battle_info_detail(battle_type, start_time)
    return unless @battle_info
    case battle_type
    when :nawabari
      "[ナワバリ]\n" + @battle_info.result.regular.splatoon_time_convert(start_time).map { |b| <<~NAWABARI
                ステージ：#{b["maps"].join(',')}
                時間：#{Time.parse(b["start"]).hour}:00 ~
      NAWABARI
      }.join("\n")
    when :league
      "[リグマ]\n" + @battle_info.result.regular.splatoon_time_convert(start_time).map { |b| <<~LEAGUE
                ステージ：#{b["maps"].join(",")}
                ルール：#{b["rule"]}
                時間：#{Time.parse(b["start"]).hour}:00 ~
      LEAGUE
      }.join("\n")
    when :gachi
      "[ガチマ]\n" + @battle_info.result.gachi.splatoon_time_convert(start_time).map { |b| <<~GACHI
                ステージ：#{b["maps"].join(",")}
                ルール：#{b["rule"]}
                時間：#{Time.parse(b["start"]).hour}:00 ~
      GACHI
      }.join("\n")
    end
  end
end

