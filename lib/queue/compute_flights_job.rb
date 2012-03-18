# This captures a job for delayed job
# The job computes flight results for a contest
class ComputeFlightsJob < Struct.new(:contest)
  
  include MannyConnect

  def perform
    @contest = contest
    @contest.compute_flights
  end

  def error(job, exception)
    Failure.create(
      :step => 'compute flights', 
      :contest_id => @contest.id,
      :manny_id => @contest.manny_synch, 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    Failure.create(
      :step => 'compute_flights', 
      :contest_id => @contest.id,
      :manny_id => @contest.manny_synch,
      :description => "Success #{@contest}")
    #Delayed::Job.enqueue ComputeContestRollupsJob.new(@contest)
    #Delayed::Job.enqueue FindStarsJob.new(@contest)
  end

end
