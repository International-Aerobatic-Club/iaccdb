json.years @years
json.contest_year @year
json.categories @airplanes do |cat, airplanes|
  json.category cat
  json.airplanes do
    json.partial! 'airplane', collection: airplanes, as: 'airplane'
  end
end
