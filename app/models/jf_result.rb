class JfResult < ActiveRecord::Base
  belongs_to :judge
  belongs_to :f_result
  belongs_to :jc_result

  include JudgeMetrics

  def judge_name
    judge.team_name
  end
end
