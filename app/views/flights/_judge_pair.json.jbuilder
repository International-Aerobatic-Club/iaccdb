json.judge do
  json.(jp.judge, :id, :name)
  json.url judge_url(jp.judge, :format => :json)
end
json.assistant do
  json.(jp.assist, :id, :name)
end

