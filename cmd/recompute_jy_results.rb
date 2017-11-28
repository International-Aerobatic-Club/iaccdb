# use rails runner cmd/recompute_jy_results.rb
# will recompute judge statistic rollups from contest rollups for a year

def do_year(year)
  puts "Queue job to compute year rollup judging statistics, #{year}"
  Delayed::Job.enqueue Jobs::ComputeYearRollupsJob.new(year)
end

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  do_year(year)
else
  puts "Specify the year"
end

