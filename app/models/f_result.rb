# Record need to recompute flight results
class FResult < ActiveRecord::Base
  attr_accessible :flight_id, :need_compute, :c_result_id

  belongs_to :flight
  belongs_to :c_result
  has_many :pf_results, :dependent => :destroy
  has_many :jf_results, :dependent => :destroy

  def to_s
    a = "f_result #{id} for #{flight}, #{c_result} "
    a += "pilot_flight results [\n\t#{pf_results.join("\n\t")}\n]" if pf_results
  end

  def results(has_soft_zero)
    compute_pf_results(has_soft_zero)
    compute_jf_results
    save
    pf_results
  end

  ###
  private
  ###

  def rank_computer
    IAC::RankComputer.instance
  end

  def compute_pf_results(has_soft_zero)
    cur_pf_results = rank_computer.computeFlight(flight, has_soft_zero)
    self.pf_results.each do |pf_result|
      self.pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
    end
    cur_pf_results.each do |pf_result|
      self.pf_results << pf_result if !self.pf_results.include?(pf_result)
    end
  end

  def compute_jf_results
    cur_jf_results = rank_computer.computeJudgeMetrics(flight)
    self.jf_results.each do |jf_result|
      self.jf_results.delete(jf_result) if !cur_jf_results.include?(jf_result)
    end
    cur_jf_results.each do |jf_result|
      self.jf_results << jf_result if !self.jf_results.include?(jf_result)
    end
  end
end
