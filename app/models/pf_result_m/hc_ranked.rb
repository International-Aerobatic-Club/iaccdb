require 'delegate'

module PfResultM

  class HcRanked < SimpleDelegator

    attr_accessor :display_rank

    def rank
      adj_flight_rank
    end

    def self.rank_computer
      Iac::RankComputer
    end

    # accepts an array of PfResults
    # returns array of HcRanked results with display_rank computed
    # based on adj_flight_rank and hors_concours attributes
    def self.computed_display_ranks(results)
      hc_ranked = []
      results.each do |result|
        hc_ranked << HcRanked.new(result)
      end
      rank_computer.compute_rankings_with_hc(hc_ranked)
      hc_ranked
    end
  end
end
