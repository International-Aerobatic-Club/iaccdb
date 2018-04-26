class CollegiateIndividualResult < Result

def compute_result
  best_total = 0.0
  best_possible = 0
  best_ratio = 0.0
  have_non_primary = false
  results = pc_results.all
  if results.size < 3
    csz = results.size
    self.qualified = false
  else
    csz = 3
    self.qualified = true
  end
  results.to_a.combination(csz) do |triple|
    total = triple.inject(0.0) { |t,r| t + r.category_value }
    possible = triple.inject(0) { |t,r| t + r.total_possible }
    non_primary = triple.inject(false) { |t,r| t || !r.category.is_primary }
    ratio = 0 < possible ? total / possible : 0.0
    if ((non_primary && !have_non_primary) || best_ratio < ratio)
      best_total, best_possible, best_ratio = total, possible, ratio
      have_non_primary ||= non_primary
    end
  end
  self.qualified &&= have_non_primary
  self.points = best_total
  self.points_possible = best_possible
  save
end

end
