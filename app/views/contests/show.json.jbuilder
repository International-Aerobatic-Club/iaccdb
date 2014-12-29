json.(@contest, :id, :start, :name, :year, :region, :city, :state, :chapter, :director)
sorted_categories = @c_results.sort do |a,b| 
  a.category.sequence <=> b.category.sequence
end
json.category_results sorted_categories do |result|
  json.partial! result
end
