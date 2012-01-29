module JudgeMetrics

  def zero_reset
    self.sigma_ri_delta = 0.0
    self.pilot_count = self.con = self.dis = 0
    self.minority_zero_ct = self.minority_grade_ct = 0
  end

  def ri
    if pilot_count && pilot_count != 0
      ri = (20.0 * sigma_ri_delta) / 
      (0.0057 * pilot_count * pilot_count + 0.1041 * pilot_count)
      ri.round(2)
    else
      0
    end
  end

  def tau
    pair_ct = pair_count || 0
    if pair_ct != 0
      tau = (con - dis).fdiv(pair_ct)
      (tau * 100).round
    else
      0
    end
  end

  def gamma
    if con && dis && 0 < (con + dis)
      g = (con - dis).fdiv(con + dis)
      (g * 100).round
    else
      0
    end
  end

end
