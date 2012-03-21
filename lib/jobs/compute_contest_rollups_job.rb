# This captures a job for delayed job
# The job computes flight results for a contest
class ComputeContestRollupsJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    say "Computing rollups for #{@contest.year_name}"
    @contest.compute_contest_rollups
  end

  def error(job, exception)
    say "Error computing rollups for #{@contest.year_name}"
    record_contest_failure('compute rollups', @contest, exception)
  end

  def success(job)
    say "Success computing contest rollups for #{@contest.year_name}"
    Delayed::Job.enqueue ComputeYearRollupsJob.new(@contest.start.year)
  end

end
