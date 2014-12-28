xml.contests do
  @contests.each do |contest|
    xml.contest do
      xml.name contest.name
      xml.city contest.city
      xml.state contest.state
      xml.chapter contest.chapter
      xml.director contest.director
      xml.region contest.region
      xml.start contest.start
    end
  end
end
