# This captures a job for delayed job
# The job computes flight results for a contest
class ComputeFlightsJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    say "Computing flights for #{@contest.year_name}"
    @contest.compute_flights
  end

  def error(job, exception)
    say "Error computing flights for #{@contest.year_name}"
    Failure.create(
      :step => 'compute flights', 
      :contest_id => @contest.id,
      :manny_id => @contest.manny_synch, 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    say "Success computing flights for #{@contest.year_name}"
    Delayed::Job.enqueue ComputeContestRollupsJob.new(@contest)
    Delayed::Job.enqueue FindStarsJob.new(@contest)
  end

end
