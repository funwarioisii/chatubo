require "thor"
require 'chatubo/bots/syake'

module Chatubo
  class CLI < Thor
    desc "syake {type} {start_time}", %Q[print each (type| syake, nawabari, gachi, league) game's stage and time]
    def syake(type, start_time=nil)
      extractor = SplatoonStageInfoExtractor.new

      case type
      when '鮭'
        extractor.fetch_coop_info!
        p extractor.get_coop_info_detail
      else
        extractor.fetch_battle_info!
        p extractor.get_battle_info_detail(type.to_sym, start_time)
      end
    end
  end
end
