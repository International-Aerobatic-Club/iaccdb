json.flight do
  json.partial! 'flight', flight: @flight
  json.contest contest_url(@flight.contest)
  json.category do
    json.partial! 'categories/category', category: @flight.category
  end
  json.pilot_results do
    json.partial! 'pilot_flights', collection: @flight.pilot_flights, :as => :pf
  end
end
