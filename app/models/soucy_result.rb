class SoucyResult < Result

def compute_best_pair
  best_total = 0.0
  best_possible = 1
  best_ratio = 0.0
  pc_results.all.combination(2) do |pair|
    total = pair[0].category_value + pair[1].category_value
    possible = pair[0].total_possible + pair[1].total_possible
    ratio = 0 < possible ? total / possible : 0.0
    if (best_ratio < ratio)
      best_total, best_possible, best_ratio = total, possible, ratio
    end
  end
  self.points = best_total
  self.points_possible = best_possible
  self.qualified = false
  save
end

def integrate_national_result(nationals)
  nationals_result = PcResult.competitive.where(pilot: pilot, contest: nationals).first
  if nationals_result
    self.points += nationals_result.category_value
    self.points_possible += nationals_result.total_possible
    self.qualified = true
    pcrs = self.pc_results.all
    self.pc_results << nationals_result unless pcrs.include?(nationals_result)
  else
    self.qualified = false
  end
  save
end

end
