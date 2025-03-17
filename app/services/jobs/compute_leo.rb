# This captures a job for delayed job
# The job computes National Point Series Championship ("Leo") results for a given year
module Jobs
class ComputeLeoJob < Struct.new(:contest)
  include JobsSay

  def perform
    @contest = contest
    year = contest.year
    @description = "#{year}"
    if (year == Time.now.year)
      make_computation(year)
    else
      say "Skipping Leo for #{@description} not current year"
    end
  end

  def make_computation(year)
    say "Computing Leo standings for #{@description}"
    leo = IAC::LeoComputer.new(year)
    leo.recompute
  end

  def error(job, exception)
    say "Error in Leo computation #{@description}"
    record_contest_failure(@description, @contest, exception)
  end

  def success(job)
    say "Success Leo computation #{@description}"
  end

end
end
