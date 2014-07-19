class InitializeTotalPossible < ActiveRecord::Migration
  def self.up
    PfResult.all.each do |pf_result|
      pf = pf_result.pilot_flight
      pf_result.total_possible = pf.sequence.total_k * 10
      pf_result.save
    end
    PcResult.all.each do |pc_result|
      pc_result.total_possible = 0
      pc_result.pf_results.each do |pf_result|
        pc_result.total_possible += pf_result.total_possible
      end
      pc_result.save
    end
  end

  def self.down
  end
end
