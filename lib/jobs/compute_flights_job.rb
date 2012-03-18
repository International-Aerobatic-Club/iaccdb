# This captures a job for delayed job
# The job computes flight results for a contest
class ComputeFlightsJob < Struct.new(:contest)
  
  def perform
    @contest = contest
    puts "Computing flights for #{@contest.year_name}"
    @contest.compute_flights
  end

  def error(job, exception)
    puts "Error computing flights for #{@contest.year_name}"
    Failure.create(
      :step => 'compute flights', 
      :contest_id => @contest.id,
      :manny_id => @contest.manny_synch, 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    puts "Success computing flights for #{@contest.year_name}"
    Delayed::Job.enqueue ComputeContestRollupsJob.new(@contest)
    Delayed::Job.enqueue FindStarsJob.new(@contest)
  end

end
