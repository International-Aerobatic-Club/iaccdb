# use rails runner lib/iac/recompute_judge_rollups.rb 
# will check all of the contests
require "iac/judge_rollups"

def do_year(year)
  puts "Compute judge rollups for #{year}"
  IAC::JudgeRollups.compute_jy_results(year)
end

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  do_year(year)
else
  contests = Contest.select("distinct year(start) as year")
  contests.each { |contest| do_year(contest.year) }
end

