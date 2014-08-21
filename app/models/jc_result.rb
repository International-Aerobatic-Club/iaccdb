class JcResult < ActiveRecord::Base
  attr_protected :id

  belongs_to :judge, :class_name => 'Member'
  belongs_to :c_result
  has_many :jf_results, :dependent => :destroy

  include JudgeMetrics

  def judge_name
    judge ? judge.name : 'missing judge'
  end

  def to_s 
    a = "jc_result for judge #{judge}"
  end

  def compute_category_totals(f_results)
    zero_reset
    cur_jf_results = []
    f_results.each do |f_result|
      f_result.jf_results.each do |jf_result|
        cur_jf_results << jf_result if jf_result.judge.judge == self.judge
      end
    end
    cur_jf_results.each do |jf_result|
      accumulate(jf_result)
      jf_results << jf_result if !jf_results.include?(jf_result)
    end
    jf_results.each do |jf_result|
      jf_results.delete(jf_result) if !cur_jf_results.include?(jf_result)
    end
    save
  end

end
