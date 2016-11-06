json.partial! 'categories/category', category: category[:cat]
json.flights do
  json.array! category[:flights] do |flight|
    json.partial! 'flights/flight', flight: flight
    json.url flight_url(flight, :format => :json)
  end
end
json.pilot_results do
  json.partial! 'pilot_result', collection: category[:pilot_results],
    :as => :pilot_result
end
json.judge_results do
  json.partial! 'judge_result', collection: category[:judge_results],
    :as => :judge_result
end

