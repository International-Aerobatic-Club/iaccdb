# This captures a job for delayed job
# The job computes flight results for a contest
module Jobs
class ComputeFlightsJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    say "Computing flights for #{@contest.year_name}"
    @contest.compute_flights
  end

  def error(job, exception)
    say "Error computing flights for #{@contest.year_name}"
    record_contest_failure('compute_flights', @contest, exception)
  end

  def success(job)
    say "Success computing flights for #{@contest.year_name}"
    Delayed::Job.enqueue ComputeContestRollupsJob.new(@contest)
  end

end
end
