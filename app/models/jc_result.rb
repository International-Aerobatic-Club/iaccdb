class JcResult < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :c_result
  has_many :jf_results

  include JudgeMetrics

  def to_s 
    a = "jc_result for judge #{judge}, need_compute is #{need_compute}"
  end

  def mark_for_calcs
    if !self.need_compute
      update_attribute(:need_compute, true)
    end
  end

  def compute_category_totals(f_result)
    if self.need_compute
      zero_reset
      cur_jf_results = []
      f_result.jf_results.each do |jf_result|
        cur_jf_results << jf_result if jf_result.judge.judge == self.judge
      end
      cur_jf_results.each do |jf_result|
        self.pilot_count += jf_result.pilot_count
        self.sigma_d2 += jf_result.sigma_d2
        self.sigma_pj += jf_result.sigma_pj
        self.sigma_p2 += jf_result.sigma_p2
        self.sigma_j2 += jf_result.sigma_j2
        self.sigma_ri_delta += jf_result.sigma_ri_delta
        self.con += jf_result.con
        self.dis += jf_result.dis
        self.minority_zero_ct += jf_result.minority_zero_ct
        self.minority_grade_ct += jf_result.minority_grade_ct
        jf_results << jf_result if !jf_results.include?(jf_result)
      end
      jf_results.each do |jf_result|
        jf_results.delete(jf_result) if !cur_jf_results.include?(jf_result)
      end
      self.need_compute = false
      save
    end
  end

end
