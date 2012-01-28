module JudgeMetrics

  def zero_reset
    self.sigma_d2 = self.sigma_pj = self.sigma_p2 = self.sigma_j2 = 0
    self.sigma_ri_delta = 0.0
    self.pilot_count = self.con = self.dis = 0
    self.minority_zero_ct = self.minority_grade_ct = 0
  end

  def rho
    if pilot_count && pilot_count != 0
      np2 = pilot_count * pilot_count
      rho = 1.0 - 6.0 * sigma_d2.fdiv(pilot_count * (np2 - 1))
      (rho * 100).round
    else
      0
    end
  end

  def cc
    if sigma_p2 && sigma_j2 && sigma_p2 != 0 && sigma_j2 != 0
      cc = sigma_pj.fdiv(Math.sqrt(sigma_p2 * sigma_j2))
      (cc * 100).round
    else
      0
    end
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
