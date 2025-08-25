#require 'iac/judge_rollups'

# This captures a job for delayed job
# The job computes metric rollups for all contests in a year
module Jobs
class ComputeYearRollupsJob < Struct.new(:year)
  
  include JobsSay

  def perform
    @year = year
    say "Computing year rollups for #{@year}"
    Iac::JudgeRollups.compute_jy_results(@year)
  end

  def error(job, exception)
    say "Error computing rollups for #{@year}"
    Failure.create(
      :step => "#{@year} rollups", 
      :description => 
        ':: ' + exception.message + " ::\n" + exception.backtrace.join("\n"))
  end

  def success(job)
    say "Success computing rollups for #{@year}"
  end

end
end
