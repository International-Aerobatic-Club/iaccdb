class PcResult < ActiveRecord::Base
  belongs_to :pilot, :class_name => 'Member'
  belongs_to :c_result
  has_many :pf_results

  def to_s 
    a = "pc_result for pilot #{pilot} value #{category_value}, "
    a += "pilot_flight results [\n\t#{pf_results.join("\n\t")}\n]" if pf_results
    a += "need_compute is #{need_compute}"
  end

  def mark_for_calcs
    if !self.need_compute
      c_result.mark_for_calcs if c_result
      update_attribute(:need_compute, true)
    end
  end

  def compute_category_totals(f_results)
    if self.need_compute
      self.category_value = 0
      cur_pf_results = []
      f_results.each do |f_result|
        f_result.pf_results.each do |pf_result|
          cur_pf_results << pf_result if pf_result.pilot_flight.pilot == pilot
        end
      end
      cur_pf_results.each do |pf_result|
        self.category_value += pf_result.adj_flight_value
        pf_results << pf_result if !pf_results.include?(pf_result)
      end
      pf_results.each do |pf_result|
        pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
      end
      self.need_compute = false
      save
    end
  end

end
