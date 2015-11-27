json.flight do
  json.partial! pf_result.flight
end
json.airplane do
  json.partial! pf_result.pilot_flight.airplane
end
json.(pf_result, :flight_rank, :adj_flight_rank, :flight_value, :adj_flight_value, :total_possible)

