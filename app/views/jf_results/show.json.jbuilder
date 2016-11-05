json.judge_flight_data do
  json.partial! 'flights/judge_pair', jp: @jf_result.judge
  json.(@jf_result, :id, :pilot_count, :tau, :rho, :gamma, :cc, :ri)
  json.(@jf_result, :pair_count, :figure_count, :flight_count)
  json.minority_zeros @jf_result.minority_zero_ct
  json.minority_grades @jf_result.minority_grade_ct
  json.average_flight_size @jf_result.avgFlightSize
  json.average_k @jf_result.avgK
  json.grades do
    json.partial! 'score', collection: @judge_grades.grades, :as => :score
  end
end
