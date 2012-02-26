# use rails runner lib/iac/recompute_judge_rollups.rb 
# will check all of the contests
require "iac/judge_rollups"

year = ARGV.empty? ? 0 : ARGV[0].to_i
year = Date.today.year if year < 1990
puts "Compute judge rollups for #{year}"
IAC::JudgeRollups.compute_jy_results(year)

