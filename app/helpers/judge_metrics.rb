module JudgeMetrics

  def zero_reset
    self.pilot_count = 0
    self.pair_count = 0
    self.ftsdxdy = 0
    self.ftsdx2 = 0
    self.ftsdy2 = 0
    self.sigma_d2 = 0
    self.sigma_ri_delta = 0.0
    self.con = self.dis = 0
    self.minority_zero_ct = self.minority_grade_ct = 0
    self.total_k = 0
    self.figure_count = 0
    self.flight_count = 0
    self.ri_total = 0
  end

  def accumulate(metrics)
    self.pilot_count += (metrics.pilot_count || 0)
    self.pair_count += (metrics.pair_count || 0)
    self.ftsdxdy += (metrics.ftsdxdy || 0)
    self.ftsdx2 += (metrics.ftsdx2 || 0)
    self.ftsdy2 += (metrics.ftsdy2 || 0)
    self.sigma_d2 += (metrics.sigma_d2 || 0)
    self.sigma_ri_delta += (metrics.sigma_ri_delta || 0)
    self.con += (metrics.con || 0)
    self.dis += (metrics.dis || 0)
    self.minority_zero_ct += (metrics.minority_zero_ct || 0)
    self.minority_grade_ct += (metrics.minority_grade_ct || 0)
    self.total_k += (metrics.total_k || 0)
    self.figure_count += (metrics.figure_count || 0)
    self.flight_count += (metrics.flight_count || 0)
    self.ri_total += (metrics.ri_total || 0)
  end

  def ri
    if flight_count && 0 < flight_count
      ri = ri_total/flight_count
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
      100
    end
  end

  def rho
    if pilot_count && 1 < pilot_count
      np2 = pilot_count * pilot_count
      rho = 1.0 - 6.0 * sigma_d2.fdiv(pilot_count * (np2 - 1))
      (rho * 100).round
    else
      100
    end
  end

  def cc
    if ftsdx2 && ftsdy2 && ftsdxdy && 0 < ftsdx2 && 0 < ftsdy2
      cc = ftsdxdy.fdiv(Math.sqrt(ftsdx2 * ftsdy2))
      (cc * 100).round
    else
      100
    end
  end

  def avgK
    if (figure_count && 0 < figure_count)
      total_k.fdiv(figure_count)
    else
      0
    end
  end

  def avgFlightSize
    if (flight_count && 0 < flight_count)
      pilot_count.fdiv(flight_count)
    else
      0
    end
  end

end
