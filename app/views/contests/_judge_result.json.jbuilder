json.judge do
  json.partial! 'members/member', member: judge_result.judge
end
json.result do
  json.partial! 'jc_results/jc_result', jc_result: judge_result
end

