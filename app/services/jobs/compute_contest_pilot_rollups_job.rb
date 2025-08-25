# This captures a job for delayed job
# The job computes flight results for a contest
module Jobs
class ComputeContestPilotRollupsJob < Struct.new(:contest)

  include JobsSay

  def perform
    say "Computing pilot rollups for #{contest.year_name}"
    make_computation
  end

  def make_computation
    computer.compute_contest_pilot_rollups
  end

  def computer
    ContestComputer.new(contest)
  end

  def error(job, exception)
    say "Error computing pilot rollups for #{contest.year_name}"
    record_contest_failure('compute pilot rollups', contest, exception)
  end

  def success(job)
    say "Success computing contest pilot rollups for #{contest.year_name}"
    Delayed::Job.enqueue FindStarsJob.new(contest)
    # for the following, TODO someday, if there is already a job
    # in the queue for the year and category, remove that,
    # because these new ones will do the job
    Delayed::Job.enqueue ComputeRegionalJob.new(contest)
    Delayed::Job.enqueue ComputeSoucyJob.new(contest)
    Delayed::Job.enqueue ComputeCollegiateJob.new(contest)
    Delayed::Job.enqueue ComputeLeo.new(contest)
  end

end
end
