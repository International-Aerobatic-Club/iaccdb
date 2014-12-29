json.category_result do
  json.category do
    json.partial! c_result.category
  end
  sorted_pilots = c_result.pc_results.sort do |a,b|
    a.category_rank <=> b.category_rank
  end
  json.pilot_results sorted_pilots do |pc_result|
    json.partial! pc_result
  end
  sorted_judges = c_result.jc_results.sort do |b,a|
    a.gamma <=> b.gamma
  end
  json.judges sorted_judges do |jc_result|
    json.partial! jc_result
  end
end
