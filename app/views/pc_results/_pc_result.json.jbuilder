json.pilot do
  json.partial! pc_result.pilot
end
json.(pc_result, :category_rank, :category_value, :total_possible, :star_qualifying)
