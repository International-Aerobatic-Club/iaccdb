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
    judges = Judge.find_all_by_judge_id(id)
    @jf_results =
      JfResult.includes(:f_result).find_all_by_judge_id(judges)
    @jf_results.sort! do |a,b|
      b.f_result.flight.contest.start <=> a.f_result.flight.contest.start
    end
    # year/category rollups stats report
    cur_year = Time.now.year
    prior_year = cur_year - 1
    jy_results_query = JyResult.includes(:category).order(
       'year DESC').where("#{prior_year} <= year").find_all_by_judge_id(id)
    jy_by_year = jy_results_query.group_by { |r| r.year }
    @j_results = [] # array of hash {year label, array of string count for category}
    jy_by_year.each do |year, jy_results| 
      j_year_results = [] # array of hash {category label, values}
      jys = jy_results.sort_by { |jy_result| jy_result.category.sequence }
      jys.each do |jy_result|
        j_year_results << "#{jy_result.pilot_count} #{jy_result.category.name}"
      end
      @j_results << { :label => year, :values => j_year_results }
    end
  end

  def cv
    id = params[:id]
    @judge = Member.find(id)
    jy_results_query = JyResult.includes(:category).order(
       "year DESC").find_all_by_judge_id(id)
    jy_by_year = jy_results_query.group_by { |r| r.year }
    jc_results_query = JcResult.includes(:c_result).find_all_by_judge_id(id)
    jc_by_year = jc_results_query.group_by { |r| r.c_result.contest.start.year }
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
          c_result = jc_result.c_result
          cat = Category.find_for_cat_aircat(c_result.category, c_result.aircat)
          cat == jy_result.category
        end
        jc_cat.each do |jc_result|
          j_cat_results << {
            :label => jc_result.c_result.contest.name, 
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
    @career_results.each do |career_line|
      puts career_line[:label]
      puts career_line[:values]
    end
    @sj_results = j_results.sort { |a,b| b <=> a }
  end

  def histograms
    @judge_team = Judge.find(params[:judge_id])
    @judge = Member.find(@judge_team.judge_id)
    @f_result = FResult.find(params[:flight_id])
    @flight = Flight.find(@f_result.flight_id)
    @pilot_flights = @flight.pilot_flights
    @figure_scores = []
    @pilot_flights.each do |pf|
      scores = Score.find_by_judge_id_and_pilot_flight_id(@judge_team.id, pf.id)
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

end
