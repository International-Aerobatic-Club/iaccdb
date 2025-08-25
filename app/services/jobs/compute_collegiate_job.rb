# This captures a job for delayed job
# The job computes collegiate results for the contest year
module Jobs
class ComputeCollegiateJob < Struct.new(:contest)

  include JobsSay

  def perform
    @year = contest.year
    @description = "#{@year}"
    if (contest.year == Time.now.year)
      make_computation
    else
      say "Skipping collegiate computation for year, #{@year}"
    end
  end

  def make_computation
    say "Computing collegiate standings for #{@description}"
    computer.recompute
  end

  def computer
    Iac::CollegiateComputer.new(@year)
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
