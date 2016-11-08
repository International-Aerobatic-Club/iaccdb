json.judge do
  json.(jp.judge, :id, :name)
  json.url judge_url(jp.judge, :format => :json)
end
if jp.assist
  json.assistant do
    json.(jp.assist, :id, :name)
  end
end

