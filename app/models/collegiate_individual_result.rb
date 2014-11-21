class CollegiateIndividualResult < Result

def compute_result
  best_total = 0.0
  best_possible = 0
  best_ratio = 0.0
  results = pc_results.all
  if results.size < 3
    csz = results.size
    self.qualified = false
  else
    csz = 3
    self.qualified = true
  end
  results.combination(csz) do |triple|
    total = triple.inject(0.0) { |t,r| t + r.category_value }
    possible = triple.inject(0) { |t,r| t + r.total_possible }
    ratio = 0 < possible ? total / possible : 0.0
    if (best_ratio < ratio)
      best_total, best_possible, best_ratio = total, possible, ratio
    end
  end
  self.points = best_total
  self.points_possible = best_possible
  save
end

end
