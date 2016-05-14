require 'delegate'

module PcResultM
  class HcRanked < SimpleDelegator

    attr_accessor :display_rank

    def rank
      category_rank
    end

    def self.rank_computer
      IAC::RankComputer.instance
    end

    # accepts an array of PcResults
    # returns array of HcRanked with display_rank computed from
    # based on category_rank and hors_concours attributes
    def self.computed_display_ranks(pc_results)
      hc_ranked = []
      pc_results.each do |pc_result|
        hc_ranked << HcRanked.new(pc_result)
      end
      rank_computer.compute_rankings_with_hc(hc_ranked)
      hc_ranked
    end
  end
end

