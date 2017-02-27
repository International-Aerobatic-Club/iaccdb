json.id pf.id
json.pilot do
  json.id pf.pilot.id
  json.name pf.pilot.name
  json.url pilot_url(pf.pilot, :format => :json)
end
json.airplane do
  json.id pf.airplane.id
  json.make pf.airplane.make
  json.model pf.airplane.model
  json.reg pf.airplane.reg
end
json.url pilot_flight_url(pf, :format => :json)
json.penalty_total pf.penalty_total
json.partial! 'pf_result', result: pf.pf_results.first
