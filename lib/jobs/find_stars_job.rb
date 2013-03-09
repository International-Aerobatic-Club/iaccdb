#require "iac/findStars"

# This captures a job for delayed job
# The job computes flight results for a contest
module Jobs
class FindStarsJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    say "Finding stars qualifying pilots for #{@contest.year_name}"
    IAC::FindStars.findStars(contest) 
  end

  def error(job, exception)
    say "Error finding stars for #{@contest.year_name}"
    record_contest_failure('find_stars', @contest, exception)
  end

  def success(job)
    say "Success finding stars for #{@contest.year_name}"
  end

end
end
