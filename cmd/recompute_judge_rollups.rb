# use rails runner cmd/recompute_judge_rollups.rb
# will recompute judge stat's all of the flights for a year

def do_year(year)
  puts "Queue jobs to compute all judging statistics for #{year}"
  contests = Contest.where(['year(start) = ?', year])
  contests.each do |contest|
    puts "Queue Judge Flight Metrics Job for #{contest}"
    Delayed::Job.enqueue Jobs::ComputeJudgeFlightMetricsJob.new(contest)
  end
end

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  do_year(year)
else
  puts "Specify the year"
end

