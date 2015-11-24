# This captures a job for delayed job
# The job computes flight results for a contest
module Jobs
class ComputeContestRollupsJob < Struct.new(:contest)

  include JobsSay

  def perform
    say "Computing rollups for #{contest.year_name}"
    computer = ContestComputer.new(contest)
    computer.compute_contest_rollups
  end

  def error(job, exception)
    say "Error computing rollups for #{contest.year_name}"
    record_contest_failure('compute rollups', contest, exception)
  end

  def success(job)
    say "Success computing contest rollups for #{contest.year_name}"
    Delayed::Job.enqueue FindStarsJob.new(contest)
    # for the following, TODO someday, if there is already a job
    # in the queue for the year and category, remove that,
    # because these new ones will do the job
    Delayed::Job.enqueue ComputeYearRollupsJob.new(contest.start.year)
    Delayed::Job.enqueue ComputeRegionalJob.new(contest)
    Delayed::Job.enqueue ComputeSoucyJob.new(contest)
    Delayed::Job.enqueue ComputeCollegiateJob.new(contest)
  end

end
end
