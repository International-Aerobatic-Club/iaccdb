# use rails runner cmd/recompute_judge_flight_metrics.rb
# will recompute judge rollups for contest

def do_contest(contest_id)
  contest = Contest.find(contest_id)
  if (contest)
    puts "Queue job to compute judge statistics rollup for #{contest}"
    Delayed::Job.enqueue Jobs::ComputeContestJudgeRollupsJob.new(contest)
  else
    puts "No contest with id #{contest_id}"
  end
end

contest = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < contest)
  do_contest(contest)
else
  puts "Specify the contest id"
end

