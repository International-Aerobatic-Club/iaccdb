require "iac/findStars"

# This captures a job for delayed job
# The job computes flight results for a contest
class FindStarsJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    say "Finding stars qualifying pilots for #{@contest.year_name}"
    IAC::FindStars.findStars(contest) 
  end

  def error(job, exception)
    say "Error finding stars for #{@contest.year_name}"
    Failure.create(
      :step => 'find stars', 
      :contest_id => @contest.id,
      :manny_id => @contest.manny_synch, 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    say "Success finding stars for #{@contest.year_name}"
  end

end
