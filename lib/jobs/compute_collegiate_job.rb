# This captures a job for delayed job
# The job computes L. Paul Soucy results for a given year
module Jobs
class ComputeCollegiateJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    @year = contest.year
    @description = "#{@year}"
    say "Computing collegiate standings for #{@description}"
    cc = IAC::CollegiateComputer.new(@year)
    cc.recompute
  end

  def error(job, exception)
    say "Error collegiate computation #{@description}"
    record_contest_failure(@description, @contest, exception)
  end

  def success(job)
    say "Success collegiate computation #{@description}"
  end

end
end
