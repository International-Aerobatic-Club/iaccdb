class JcResult < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :contest
  belongs_to :category

  include JudgeMetrics

  def judge_name
    judge ? judge.name : 'missing judge'
  end

  def to_s 
    "jc_result for #{judge}, #{contest}, #{category}"
  end

  def compute_category_totals
    zero_reset
    flights = contest.flights.where(category: category)
    flights.each do |flight|
      flight.jf_results.each do |jf_result|
        accumulate(jf_result) if jf_result.judge.judge == self.judge
      end
    end
    save
  end
end

