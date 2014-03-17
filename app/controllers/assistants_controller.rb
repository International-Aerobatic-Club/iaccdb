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
    assists = Judge.find_all_by_assist_id(id)
    scores = Score.find_all_by_judge_id(assists)
    pilot_flights = PilotFlight.find_all_by_id(scores.map { |s| s.pilot_flight_id })
    flights_history = Flight.find_all_by_id(pilot_flights.map { |f| f.flight_id })
    cur_year = Time.now.year
    prior_year = cur_year - 1
    flights_history = flights_history.delete_if { |flight| flight.contest.start.year < prior_year }

    jy_results_query = JyResult.includes(:category).order(
       'year DESC').where("#{prior_year} <= year").find_all_by_judge_id(assistants)
    jy_by_year = jy_results_query.group_by { |r| r.year }
    @j_results = [] # array of hash {year label, array of string count for category}
    @totals = {} # hash indexed by year label, value is total pilots for year
    jy_by_year.each do |year, jy_results| 
      j_year_results = [] # array of hash {category label, values}
      jys = jy_results.sort_by { |jy_result| jy_result.category.sequence }
      total_count = 0
      jys.each do |jy_result|
        j_year_results << "#{jy_result.pilot_count} #{jy_result.category.name}"
        total_count += jy_result.pilot_count
      end
      @j_results << { :label => year, :values => j_year_results }
      @totals[year] = total_count
    end
  end

end
