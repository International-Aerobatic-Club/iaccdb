json.pilot do
  json.partial! 'members/member', member: pilot_result[:member]
  json.chapter pilot_result[:chapter]
end
json.airplane do
  json.partial! 'airplanes/airplane', airplane: pilot_result[:airplane]
end
json.result do
  json.partial! 'pc_results/pc_result', pc_result: pilot_result[:overall]
end

