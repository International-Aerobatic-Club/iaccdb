json.flight do
  json.partial! pf_result.f_result.flight
end
json.(pf_result, :flight_rank, :adj_flight_rank, :flight_value, :adj_flight_value, :total_possible)

