json.flight do
  json.partial! 'flight', flight: @flight
  json.contest do
    json.partial! 'contest', contest: @flight.contest
    json.url contest_url(@flight.contest, :format => :json)
  end
  json.category do
    json.partial! 'categories/category', category: @flight.category
  end
  json.pilot_results do
    json.partial! 'pilot_flights', collection: @flight.pilot_flights, :as => :pf
  end
  json.line_judges do
    json.partial! 'line_judges', collection: @flight.jf_results, :as => :jfr
  end
end
