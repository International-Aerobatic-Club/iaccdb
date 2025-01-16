class CollegiateIndividualResult < Result

  def compute_result

    # Convenience var
    pc_count = pc_results.count

    # Must have at least 3 contests to qualify
    self.qualified = (pc_count >= 3)

    # Reorganize the results into a 2D array, then sort by points-scored divided by possible-points, in descending order
    sorted_results = pc_results.sort_by{ |pcr| -pcr.pct_possible }.map{ |pcr| [pcr.category_value, pcr.total_possible] }

    # Take the top n results, where n is the actual number of results *or* 3, whichever is less
    top_results = sorted_results.first([pc_count, 3].min)

    self.points = top_results.map{ |cv, pp| cv/pp }.inject(:+) * 100 / top_results.count
    self.points_possible = 100

    # Save the updated result
    save!

  end

end
