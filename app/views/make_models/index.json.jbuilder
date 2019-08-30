json.airplane_makes @make_models.keys do |make|
  json.make make
  json.airplane_models @make_models[make] do |mm|
    json.extract! mm, :make, :model,
      :empty_weight_lbs, :max_weight_lbs, :horsepower,
      :seats, :wings
  end
end
