# This captures a job for delayed job
# The job computes judge category rollups for a contest
module Jobs
class ComputeContestJudgeRollupsJob < Struct.new(:contest)

  include JobsSay

  def perform
    say "Computing judge rollups for #{contest.year_name}"
    computer = ContestComputer.new(contest)
    computer.compute_contest_judge_rollups
  end

  def error(job, exception)
    say "Error computing rollups for #{contest.year_name}"
    record_contest_failure('compute rollups', contest, exception)
  end

  def success(job)
    say "Success computing contest judge rollups for #{contest.year_name}"
    Delayed::Job.enqueue ComputeYearRollupsJob.new(contest.start.year)
  end

end
end
