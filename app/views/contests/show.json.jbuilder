json.(@contest, :id, :start, :name, :year, :region, :city, :state, :chapter, :director)
json.category_results @categories do |result|
  json.partial! result
end

