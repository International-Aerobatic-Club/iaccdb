class AssistantsController < ApplicationController
  def index
    @assistants = Member.find_by_sql("select 
      m.given_name, m.family_name, m.id
      from members m where m.id in (select distinct assist_id from judges)
      order by  m.family_name, m.given_name")
  end

  def show
    id = params[:id]
    @assistant = Member.find(id)
    assists = Judge.where(assist_id: id)
    scores = Score.includes(:flight).where(judge_id: assists)
    flights = scores.map { |s| s.flight }
    # this following block because there's a problem with 
    # removing dependent records TODO
    @flights_history = flights.uniq.reject { |f| f == nil || f.contest == nil }
    @flights_history.sort! { |a,b| b.contest.start <=> a.contest.start }
    cur_year = Time.now.year
    prior_year = cur_year - 1
    flights_recent = @flights_history.select { |flight| prior_year <= flight.contest.year }
    flights_by_year = flights_recent.group_by { |f| f.contest.year }
    @flight_assists = [] # array of hash indexed by year, value is string count and category
    @totals = {} # hash indexed by year label, value is total pilots for year
    flights_by_year.each do |year, flights| 
      flight_year_results = {} # hash {category label, count}
      fys = flights.sort_by { |flight| flight.category.sequence }
      total_count = 0
      fys.each do |flight|
        flight_year_results[flight.category] ||= 0
        flight_year_results[flight.category] += flight.pilot_flights.count
        total_count += flight.pilot_flights.count
      end
      flight_counts_by_category = []
      Category.order(:sequence).each do |cat|
        if flight_year_results[cat]
          flight_counts_by_category << "#{flight_year_results[cat]} #{cat.name}"
        end
      end
      @flight_assists << { label: year, values: flight_counts_by_category }
      @totals[year] = total_count
    end
    @flight_assists.sort! { |a,b| b[:label] <=> a[:label] }
  end

end
