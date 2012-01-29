class JcResult < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :c_result
  has_many :jf_results

  include JudgeMetrics

  def judge_name
    judge.name
  end

  def to_s 
    a = "jc_result for judge #{judge}"
  end

  def compute_category_totals(f_results)
    zero_reset
    self.rho = 0
    self.cc = 0
    self.pair_count = 0
    cur_jf_results = []
    f_results.each do |f_result|
      f_result.jf_results.each do |jf_result|
        cur_jf_results << jf_result if jf_result.judge.judge == self.judge
      end
    end
    cur_jf_results.each do |jf_result|
      self.pilot_count += jf_result.pilot_count
      self.pair_count += jf_result.pair_count
      self.rho += jf_result.rho
      self.cc += jf_result.cc
      self.sigma_ri_delta += jf_result.sigma_ri_delta
      self.con += jf_result.con
      self.dis += jf_result.dis
      self.minority_zero_ct += jf_result.minority_zero_ct
      self.minority_grade_ct += jf_result.minority_grade_ct
      jf_results << jf_result if !jf_results.include?(jf_result)
    end
    flight_count = cur_jf_results.length
    if (0 < flight_count)
      self.rho = (self.rho.fdiv(flight_count)).round
      self.cc = (self.cc.fdiv(flight_count)).round
    else
      self.rho = self.cc = 0
    end
    jf_results.each do |jf_result|
      jf_results.delete(jf_result) if !cur_jf_results.include?(jf_result)
    end
    save
  end

end
