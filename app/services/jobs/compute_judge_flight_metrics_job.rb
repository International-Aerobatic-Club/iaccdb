# This captures a job for delayed job
# The job computes judge flight metrics for a contest
module Jobs
class ComputeJudgeFlightMetricsJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    say "Computing judge metrics for flights in #{@contest.year_name}"
    computer = ContestComputer.new(@contest)
    computer.compute_judge_metrics
  end

  def error(job, exception)
    say "Error computing flights for #{@contest.year_name}"
    record_contest_failure('compute_flights', @contest, exception)
  end

  def success(job)
    say "Success computing judge metrics for flights in #{@contest.year_name}"
    Delayed::Job.enqueue ComputeContestJudgeRollupsJob.new(@contest)
  end

end
end
