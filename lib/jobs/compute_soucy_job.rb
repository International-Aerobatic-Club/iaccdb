# This captures a job for delayed job
# The job computes L. Paul Soucy results for a given year
module Jobs
class ComputeSoucyJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @contest = contest
    year = contest.year
    @description = "#{year}"
    say "Computing L. Paul Soucy standings for #{@description}"
    soucy = IAC::SoucyComputer.new(year)
    soucy.recompute
  end

  def error(job, exception)
    say "Error L. Paul Soucy computation #{@description}"
    record_contest_failure(@description, @contest, exception)
  end

  def success(job)
    say "Success L. Paul Soucy computation #{@description}"
  end

end
end
