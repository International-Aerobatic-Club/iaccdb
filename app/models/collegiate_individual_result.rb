class CollegiateIndividualResult < Result

  def compute_result

    # Convenience vars
    pc_count = pc_results.count
    qual_count = pc_results.where.not(category: Category.where(category: ['primary', 'four minute'])).count

    # Must have at least 3 contests to qualify
    self.qualified = (qual_count >= 3)

    # Sort the results in descending order of %pp, then take the top 3 (or fewer, if less than 3 are present)
    top_results = pc_results.map(&:pct_possible).sort.reverse.first([pc_count, 3].min)

    # Average the top results
    self.points = top_results.sum / top_results.size

    # Since the results are presented as a percentage, the maximum number of possible points is always 100
    self.points_possible = 100

    # Save the updated result
    save!

  end

end
