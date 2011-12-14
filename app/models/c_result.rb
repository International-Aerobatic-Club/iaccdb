# Record need to recompute category results
class CResult < ActiveRecord::Base
  belongs_to :contest
  has_many :pc_results, :dependent => :destroy
  has_many :f_results

  def mark_for_calcs
    if !need_compute
      update_attribute(:need_compute, true)
    end
  end

  def compute_category_totals_and_rankings
    if need_compute
      cat_flights = contest.flights.all(:conditions => {
        :category => category, :aircat => aircat })
      cur_pc_results = Set.new
      cur_f_results = []
      cat_flights.each do |flight|
        f_result = flight.results.first
        cur_pc_results |= pc_results_for_flight(f_result)
        puts "Have cur_pc_results for #{flight} is #{cur_pc_results.to_a}"
        cur_f_results << f_result
      end
      f_results.each do |f_result|
        f_results.delete(f_result) if !cur_f_results.include?(f_result)
      end
      cur_f_results.each do |f_result|
        f_results << f_result if !f_results.include?(f_result)
      end
      pc_results.each do |pc_result|
        pc_results.delete(pc_result) if !cur_pc_results.include?(pc_result)
      end
      cur_pc_results.each do |pc_result|
        pc_results << pc_result if !pc_results.include?(pc_result)
        pc_result.compute_category_totals(f_results)
      end
# do ranking
      need_compute = false
      save
    end
  end

  ###
  private
  ###

  def pc_results_for_flight(f_result)
    rpc_results = []
    f_result.pf_results.each do |pf_result|
    # this is double-booking the pc_results
      pilot = pf_result.pilot_flight.pilot
      pc_result = pc_results.first(:conditions => { 
        :pilot_id => pilot }) || 
        pc_results.build(:pilot => pilot)
      rpc_results << pc_result
      puts "Have pc_result #{pc_result} pc_results contains #{pc_results}"
    end
    rpc_results.to_set
  end

end
