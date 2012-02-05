# use rails runner cmd/exportJudgeFlightMetrics.rb <file>

arr = %w(judge pilot_count rho cc ri tau gamma)
  puts arr.join(';')
JfResult.all.each do |jf_result|
  arr = [jf_result.judge.judge_id]
  arr << jf_result.pilot_count
  arr << jf_result.rho
  arr << jf_result.cc
  arr << jf_result.ri
  arr << jf_result.tau
  arr << jf_result.gamma
  puts arr.join(';')
end
