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
    @jy_results = JyResult.includes(:category).order(
       "year DESC").find_all_by_judge_id(id)
    jy_by_year = @jy_results.group_by { |r| r.year }
    @jc_results = JcResult.includes(:c_result).find_all_by_judge_id(id)
    jc_by_year = @jc_results.group_by { |r| r.c_result.contest.start.year }
    j_results = {}
    jy_by_year.each do |year, jy_results| 
      j_results[year] ||= []
      jys = jy_results.sort_by { |jy_result| jy_result.category.sequence }
      jc_results = jc_by_year[year]
      jys.each do |jy_result|
        j_cat_results = []
        jc_cat = jc_by_year[year].select do |jc_result| 
          c_result = jc_result.c_result
          cat = Category.find_for_cat_aircat(c_result.category, c_result.aircat)
          cat == jy_result.category
        end
        jc_cat.each do |jc_result|
          j_cat_results << [jc_result.c_result.contest.name, jc_result]
        end
        j_cat_results << ['overall', jy_result]
        j_results[year] << [jy_result.category.name, j_cat_results]
      end
    end
    @sj_results = j_results.sort { |a,b| b <=> a }
    @sj_results.each { |v| puts v }
  end

end
