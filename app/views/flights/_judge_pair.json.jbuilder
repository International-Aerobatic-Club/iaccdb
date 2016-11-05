json.judge do
  json.(jp.judge, :id, :name)
  json.url judge_url(jp.judge)
end
json.assistant do
  json.(jp.assist, :id, :name)
end

