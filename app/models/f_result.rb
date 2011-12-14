# Record need to recompute flight results
class FResult < ActiveRecord::Base
  belongs_to :flight
  belongs_to :c_result
  has_many :pf_results

  def mark_for_calcs
    if !need_compute
      update_attribute(:need_compute, true)
      contest.mark_for_calcs(flight)
    end
  end

  def results
    if need_compute
      cur_pf_results = IAC::RankComputer.computeFlight(flight)
      pf_results.each do |pf_result|
        pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
      end
      cur_pf_results.each do |pf_result|
        pf_results << pf_result if !pf_results.include?(pf_result)
      end
      need_compute = false
      save
    end
  end

end
