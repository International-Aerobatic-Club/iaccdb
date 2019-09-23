json.(flight, :id, :name)
json.url flight_url(flight, :format => :json)
json.categories do
  json.array! flight.categories,
    partial: 'categories/category', as: :category
end
