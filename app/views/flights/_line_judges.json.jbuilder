json.partial! 'judge_pair', jp: jfr.judge
json.(jfr, :id, :pilot_count, :tau, :rho, :gamma, :cc, :ri)
json.(jfr, :pair_count, :figure_count, :flight_count)
json.minority_zeros jfr.minority_zero_ct
json.minority_grades jfr.minority_grade_ct
json.average_flight_size jfr.avgFlightSize
json.average_k jfr.avgK
json.url jf_result_url(jfr, :format => :json)

