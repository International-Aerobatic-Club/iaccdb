json.(@contest, :id, :start, :name, :year, :region, :city, :state, :chapter, :director)
json.category_results @categories do |category_result|
  logger.debug "@categories CLASS #{@categories.inspect}"
  json.partial! 'categories/category', category: category_result[:cat]
end

