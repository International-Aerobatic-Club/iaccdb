class JfResult < ActiveRecord::Base
  attr_protected :id

  belongs_to :judge
  belongs_to :flight

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

  def to_s
    "judge #{judge}\n"\
    "pilot count #{pilot_count}\n"\
    "sigma_ri_delta #{sigma_ri_delta}\n"\
    "con #{con}\n"\
    "dis #{dis}\n"\
    "minority_zero_ct #{minority_zero_ct}\n"\
    "minority_grade_ct #{minority_grade_ct}\n"\
    "ftsdx2 #{ftsdx2}\n"\
    "ftsdxdy #{ftsdxdy}\n"\
    "ftsdy2 #{ftsdy2}\n"\
    "sigma_d2 #{sigma_d2}\n"\
    "pair_count #{pair_count}\n"\
    "total_k #{total_k}\n"\
    "figure_count #{figure_count}\n"\
    "flight_count #{flight_count}\n"\
    "ri_total #{ri_total}"
  end
end
