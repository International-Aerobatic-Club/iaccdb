class JfResult < ActiveRecord::Base
  attr_protected :id

  belongs_to :judge
  belongs_to :f_result
  belongs_to :jc_result

  include JudgeMetrics

  def judge_name
    judge.team_name
  end

  def pair_count
    if pilot_count
      (pilot_count * pilot_count - pilot_count) / 2
    else
      0
    end
  end
end
