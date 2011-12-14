class PcResult < ActiveRecord::Base
  belongs_to :pilot, :class_name => 'Member'
  belongs_to :c_result
  has_many :pf_results

  def mark_for_calcs
    if !need_compute
      c_result.mark_for_calcs if c_result
      update_attribute(:need_compute, true)
    end
  end

  def compute_category_totals(f_results)
    if need_compute
      category_value = 0
      cur_pf_results = []
      f_results.each do |f_result|
        f_result.pf_results.each do |pf_result|
          cur_pf_results << pf_result if pf_result.pilot_flight.pilot == pilot
        end
      end
      cur_pf_results.each do |pf_result|
        category_value += pf_result.adj_flight_value
        pf_results << pf_result if !pf_results.include?(pf_result)
      end
      pf_results.each do |pf_result|
        pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
      end
      need_compute = false
      save
    end
  end

end
