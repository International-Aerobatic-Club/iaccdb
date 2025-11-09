json.(contest, :id, :name, :city, :state, :start, :chapter, :director, :region)
json.has_results !contest.flights.empty?
json.url contest_url(contest, format: :json)
