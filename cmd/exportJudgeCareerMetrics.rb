# use rails runner cmd/exportJudgeFlightMetrics.rb <file>

cols = [:pilot_count, :sigma_ri_delta, :con, :dis, :minority_zero_ct,
       :minority_grade_ct, :pair_count, :ftsdx2, :ftsdy2, :ftsdxdy, :sigma_d2,
       :total_k, :figure_count, :flight_count]
head = %w{judge_id pilot_count rho ri gamma flight_count}
puts head.join(',')
jy_results = JyResult.select(
  cols.collect { |col| "sum(#{col}) as #{col}" }.join(',') + 
    ", judge_id").group(:judge_id)
jy_results.each do |jy_result|
  arr = [jy_result.judge_id]
  arr << jy_result.pilot_count
  arr << jy_result.cc
  arr << jy_result.ri
  arr << jy_result.gamma
  arr << jy_result.flight_count
  puts arr.join(',')
end
