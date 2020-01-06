class ContestMergeService
  def initialize(contest)
    @contest = contest
  end

  def merge_contest(other_contest)
    other_contest.jc_results.update_all(contest_id: @contest.id)
    other_contest.pc_results.update_all(contest_id: @contest.id)
    other_contest.flights.update_all(contest_id: @contest.id)
  end
end
