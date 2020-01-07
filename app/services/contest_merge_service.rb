class ContestMergeService
  attr_reader :categories

  class CategoryOverlapError < ArgumentError
    attr_reader :overlapping_categories

    def initialize(overlap)
      super("Category overlap for #{overlap.map(&:name).join(', ')}")
      @overlapping_categories = overlap
    end
  end

  def initialize(contest)
    @contest = contest
    @categories = contest_categories(contest)
  end

  def contest_categories(contest)
    [
      contest.flights.map(&:categories).map(&:to_a),
      contest.jc_results.map(&:category),
      contest.pc_results.map(&:category)
    ].flatten.uniq
  end

  def merge_contest(other_contest)
    other_cats = contest_categories(other_contest)
    overlap = other_cats & categories
    raise CategoryOverlapError.new(overlap) unless (overlap).empty?
    other_contest.jc_results.update_all(contest_id: @contest.id)
    other_contest.pc_results.update_all(contest_id: @contest.id)
    other_contest.flights.update_all(contest_id: @contest.id)
  end
end
