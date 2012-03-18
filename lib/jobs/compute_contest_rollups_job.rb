# This captures a job for delayed job
# The job computes flight results for a contest
class ComputeContestRollupsJob < Struct.new(:contest)
  
  def perform
    @contest = contest
    puts "Computing rollups for #{@contest.year_name}"
    @contest.compute_contest_rollups
  end

  def error(job, exception)
    puts "Error computing rollups for #{@contest.year_name}"
    Failure.create(
      :step => 'compute rollups', 
      :contest_id => @contest.id,
      :manny_id => @contest.manny_synch, 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    puts "Success computing contest rollups for #{@contest.year_name}"
    Delayed::Job.enqueue ComputeYearRollupsJob.new(@contest.start.year)
  end

end
