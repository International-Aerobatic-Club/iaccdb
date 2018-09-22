year_links = @years.collect { |y| contests_url(year: y, :format => :json) }
json.years year_links
json.contest_year @year
json.contests do
  json.array! @contests + @future_contests,
    partial: 'contests/contest', :as => :contest
end
