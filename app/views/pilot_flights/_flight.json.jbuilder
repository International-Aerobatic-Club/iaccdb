json.(flight, :id, :name)
json.url flight_url(flight, :format => :json)
json.category flight.category.name
