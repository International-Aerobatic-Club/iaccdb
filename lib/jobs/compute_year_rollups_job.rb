require 'iac/judge_rollups'

# This captures a job for delayed job
# The job computes metric rollups for all contests in a year
class ComputeYearRollupsJob < Struct.new(:year)
  
  def perform
    @year = year
    puts "Computing year rollups for #{@year}"
    IAC::JudgeRollups.compute_jy_results(@year)
  end

  def error(job, exception)
    puts "Error computing rollups for #{@year}"
    Failure.create(
      :step => 'year rollups #{@year}', 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    puts "Success computing rollups for #{@year}"
  end

end
