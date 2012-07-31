require 'iac/rank_computer.rb'

# Record need to recompute category results
class CResult < ActiveRecord::Base
  belongs_to :contest
  has_many :pc_results, :dependent => :destroy
  has_many :jc_results, :dependent => :destroy
  has_many :f_results, :dependent => :nullify

  def to_s 
    "c_result #{id} for #{contest}, #{category}, #{aircat}"
  end

  def display_category
    "#{category} #{'Glider' if aircat == 'G'}"
  end

  def rank_computer
    IAC::RankComputer.instance
  end

  def compute_category_totals_and_rankings(force = false)
    cat_flights = contest.flights.all(:conditions => {
      :category => category, :aircat => aircat })
    cur_pc_results = Set.new
    cur_jc_results = Set.new
    cur_f_results = []
    cat_flights.each do |flight|
      f_result = flight.results.first
      cur_pc_results |= pc_results_for_flight(f_result)
      cur_jc_results |= jc_results_for_flight(f_result)
      cur_f_results << f_result
    end
    f_results.each do |f_result|
      f_results.delete(f_result) if !cur_f_results.include?(f_result)
    end
    cur_f_results.each do |f_result|
      f_results << f_result if !f_results.include?(f_result)
    end
    pc_results.each do |pc_result|
      if cur_pc_results.include?(pc_result)
        pc_result.compute_category_totals(f_results)
      else
        pc_results.delete(pc_result) 
      end
    end
    rank_computer.computeCategory(self)
    jc_results.each do |jc_result|
      if cur_jc_results.include?(jc_result)
        jc_result.compute_category_totals(f_results)
      else
        jc_results.delete(jc_result)
      end
    end
    save
  end

  ###
  private
  ###

  def pc_results_for_flight(f_result)
    rpc_results = []
    f_result.pf_results.each do |pf_result|
      pilot = pf_result.pilot_flight.pilot
      pc_result = pc_results.first(:conditions => { 
        :pilot_id => pilot })
      if !pc_result
        pc_result = pc_results.build(:pilot => pilot)
        save # so next round finds the new result
      end
      rpc_results << pc_result
    end
    rpc_results.to_set
  end

  def jc_results_for_flight(f_result)
    rjc_results = []
    f_result.jf_results.each do |jf_result|
      judge = jf_result.judge.judge
      jc_result = jc_results.first(:conditions => { 
        :judge_id => judge })
      if !jc_result
        jc_result = jc_results.build(:judge => judge)
        save # so next round finds the new result
      end
      rjc_results << jc_result
    end
    rjc_results.to_set
  end

end
