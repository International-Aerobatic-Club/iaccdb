json.years @years
json.contest_year @year
json.contests do
  json.array! @contests, partial: 'contests/contest', :as => :contest
end
