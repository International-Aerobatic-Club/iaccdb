json.(@contest, :id, :start, :name, :year, :region, :city, :state, :chapter, :director)
json.category_results @categories do |category_result|
  json.partial! 'category', category: category_result
end

