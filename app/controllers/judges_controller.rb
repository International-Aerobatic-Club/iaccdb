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
        }
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
        :label => 'All categories',
        :values => year_rollup
      }
      j_results[year] << {
        :label => "#{year} rollup",
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
    @sj_results.each do |year, year_stats| 
      puts year
      year_stats.each do |cat_stats|
        puts cat_stats[:label]
        cat_stats[:values].each do |cat_line|
          puts cat_line[:label]
          puts cat_line[:values]
        end
      end
    end
  end

end
