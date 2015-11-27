json.pilot do
  json.partial! pc_result.pilot
end
json.(pc_result, :category_rank, :category_value, :total_possible, :star_qualifying)
pilot_flights = pc_result.pf_results.sort do |a,b|
  a.flight.sequence <=> b.flight.sequence
end
json.flight_results pilot_flights do |pf_result|
  json.partial! pf_result
end
