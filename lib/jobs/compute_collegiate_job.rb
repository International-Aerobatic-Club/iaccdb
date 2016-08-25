# This captures a job for delayed job
# The job computes collegiate results for the contest year
module Jobs
class ComputeCollegiateJob < Struct.new(:contest)
  
  include JobsSay

  def perform
    @year = contest.year
    @description = "#{@year}"
    say "Computing collegiate standings for #{@description}"
    cc = IAC::CollegiateComputer.new(@year)
    cc.recompute
  end

  def computer
    IAC::CollegiateComputer.new(@year)
  end

  def error(job, exception)
    say "Error collegiate computation #{@description}"
    record_contest_failure(@description, contest, exception)
  end

  def success(job)
    say "Success collegiate computation #{@description}"
  end

end
end
