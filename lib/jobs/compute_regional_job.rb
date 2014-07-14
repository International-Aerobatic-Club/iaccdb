# This captures a job for delayed job
# The job computes regional series results for a given region and year
module Jobs
class ComputeRegionalJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    @description = "Region #{contest.region}, year #{contest.year}"
    say "Computing regional series standings for #{@description}"
    IAC::RegionalSeries.compute_regional_for_contest(contest) 
  end

  def error(job, exception)
    say "Error regional series computation #{@description}"
    record_contest_failure(@description, @contest, exception)
  end

  def success(job)
    say "Success regional series computation #{@description}"
  end

end
end
