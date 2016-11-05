json.judge_flight_data do
  json.(@jf_result, :id, :rho, :gamma, :ri, :cc, :tau)
  json.partial! 'flights/judge_pair', jp: @jf_result.judge
end
