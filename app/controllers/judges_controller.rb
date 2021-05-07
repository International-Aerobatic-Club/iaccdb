class JudgesController < ApplicationController
  def index
    @judges = Member.find_by_sql("select
      m.given_name, m.family_name, m.id
      from members m where m.id in (select distinct judge_id from judges)
      order by  m.family_name, m.given_name")
  end

  def show
    id = params[:id]
    @judge = Member.find(id)
    judges = Judge.where(judge: @judge)
    @jf_results = JfResult.where(judge: judges)
    @jf_results = @jf_results.to_a.sort do |a,b|
      b.flight.contest.start <=> a.flight.contest.start
    end
    # year/category rollups stats report
    cur_year = Time.now.year
    prior_year = cur_year - 1
    jy_results_query = JyResult.includes(:category).order(
       year: :desc).where(['? <= year', prior_year]).where(:judge_id => id)
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

  def cv
    id = params[:id]
    @judge = Member.find(id)
    jy_results_query = JyResult.includes(:category).order(
       year: :desc).where(:judge_id => id)
    jy_by_year = jy_results_query.group_by { |r| r.year }
    jc_results_query = JcResult.includes([:category, :contest]).where(:judge_id => id)
    jc_by_year = jc_results_query.group_by { |r| r.contest.start.year }
    career_category_results = {} # hash by category
    career_rollup = JyResult.new :judge => @judge
    career_rollup.zero_reset
    j_results = {} # hash by year
    jy_by_year.each do |year, jy_results|
      j_results[year] = []
      year_rollup = JyResult.new :year => year, :judge => @judge
      year_rollup.zero_reset
      jc_results = jc_by_year[year]
      jys = jy_results.sort_by { |jy_result| jy_result.category.sequence }
      jys.each do |jy_result|
        j_cat_results = []
        jc_cat = jc_by_year[year].select do |jc_result|
          jc_result.category == jy_result.category
        end
        jc_cat.each do |jc_result|
          j_cat_results << {
            :label => jc_result.contest.name,
            :values => jc_result
          }
        end
        j_cat_results << {
          :label => 'Category rollup',
          :values => jy_result
        } if 1 < jc_cat.length
        j_results[year] << {
          :label => jy_result.category.name,
          :values => j_cat_results
        }
        year_rollup.accumulate(jy_result)
        if !career_category_results[jy_result.category]
          career_category_results[jy_result.category] =
            JyResult.new(:year => year,
              :category => jy_result.category,
              :judge => @judge)
          career_category_results[jy_result.category].zero_reset
        end
        career_category_results[jy_result.category].accumulate(jy_result)
      end
      year_rollup_entry = {
        :label => "#{year} rollup",
        :values => year_rollup
      }
      j_results[year] << {
        :label => 'All categories',
        :values => [year_rollup_entry]
      }
      career_rollup.accumulate(year_rollup)
    end
    jcs = career_category_results.sort_by { |category, jy_result| category.sequence }
    @career_results = []
    jcs.each do |category, jy_result|
      @career_results << {
        :label => category.name,
        :values => jy_result
      }
    end
    @career_results << {
      :label => 'All categories',
      :values => career_rollup
    }
    @sj_results = j_results.sort { |a,b| b <=> a }
  end

  def histograms
    @judge_team = Judge.find(params[:judge_id])
    @judge = Member.find(@judge_team.judge_id)
    @flight = Flight.find(params[:flight_id])
    @pilot_flights = @flight.pilot_flights
    @figure_scores = []
    @pilot_flights.each do |pf|
      scores = pf.scores.where(:judge => @judge_team.id).first
        puts "Scores #{scores}"
      scores.values.each_with_index do |v, f|
        @figure_scores[f] ||= []
        @figure_scores[f] << v
      end
    end
    @figure_histograms = []
    @figure_scores.each_with_index do |scores, f|
      @figure_histograms[f] ||= {}
      scores.each do |s|
        if s && s <= 100 then
          s = s/10.0
          s_count = @figure_histograms[f][s] || 0
          @figure_histograms[f][s] = s_count + 1
        end
      end
    end
  end


  # Report judging activity relevant to implement Rules 2.6.1, 2.6.2, and 2.6.3
  def activity
    # Hash with one array per IAC number, with each array element being another
    # array that describes a bit of contest experience relevant to Section 2.6
    # of the Rule Book:
    #  - Contest ID (for use in hyperlinks from iac.org to iaccdb.org)
    #  - Role (Chief Judge, Chief Assistant, Line Judge, etc.)
    #  - Boolean indicating whether the contest is Nationals or not
    #  - Category (Prim, Spt, Int, Adv, Unl)
    #  - Flight (Known, Free, Unknown)
    #  - Number of pilot flights
    @experience = Hash.new { |h,k| h[k] = Array.new }

    # Create a hash of Member.id => Member.iac_id
    mh = Member.pluck(:id, :iac_id).to_h

    # 'year' may be passed in via the HTTP GET request.
    # If not, use the year of the newest Contest.
    @year = params[:year] || Contest.order(:start).last.start.year

    # Create a hash of Category.id => Category.name
    # TODO should this be category and aircat instead of name?
    #   If a flight was only recorded in a synthetic
    #   category, that will be the category found
    ch = Category.pluck(:id, :name).to_h

    # Get all Contest objects for the year in question
    Contest.where(['year(start) = ?', @year]).includes(
      :flights
    ).find_each do |contest|

      # Convenience var
      nats = (contest.region == "National")

      # For each flight (e.g., Known/Free/Unknown)
      contest.flights.find_each do |flight|
        # report only one category so the flight is not double-counted
        # order by sequence so the one chosen is a "regular" category
        # however if the flight was only recorded in a synthetic
        # category, that will be the category found
        category = ch[flight.categories.order(:sequence).first.id]

        # Convenience vars
        pf_count = flight.pilot_flights.all.size # Number of pilot flights
        fname = flight.name

        # Tally Chief Judge experience
        @experience[mh[flight.chief_id]] <<
          [contest.id, 'Chief Judge', nats,
           category, fname, pf_count] if flight.chief_id

        # Tally Chief Assistant experience
        # TODO: Expand to handle multiple Chief Assistants
        @experience[mh[flight.assist_id]] <<
          [contest.id, 'Chief Assistant', nats,
           category, fname, pf_count] if flight.assist_id

        # Tally experience for Line Judges and Line Judge Assistants
        Judge.joins(scores: [:pilot_flight]).where(
          pilot_flights: { flight_id: flight.id }
        ).distinct.find_each do |judge|
          @experience[mh[judge.judge_id]] <<
            [contest.id, 'Line Judge', nats, category, fname, pf_count]
          @experience[mh[judge.assist_id]] <<
            [contest.id, 'Line Assistant', nats,
             category, fname, pf_count] if judge.assist_id
        end

        # Tally experience competing in Adv/Unl, per 2.6.1(c)
        flight.pilot_flights.find_each do |pf|
          @experience[mh[pf.pilot_id]] <<
            [contest.id, 'Competitor', nats, category, fname, 1]
        end
      end
    end

    response = { 'Year' => @year, 'Activity' => @experience }
    render json: response
  end
end
