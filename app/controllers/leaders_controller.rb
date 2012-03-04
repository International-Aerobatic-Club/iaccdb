class LeadersController < ApplicationController
  def judges
    @year = params[:year] || Time.now.year
    @years = JyResult.select("distinct year").all.collect{|jy_result|
    jy_result.year}.sort{|a,b| b <=> a}
    jy_results = JyResult.includes(:category, :judge).select(
      [:pilot_count, :sigma_ri_delta, :con, :dis, :minority_zero_ct,
       :minority_grade_ct, :pair_count, :ftsdx2, :ftsdy2, :ftsdxdy, :sigma_d2,
       :total_k, :figure_count, :flight_count].collect { |col|
      "sum(#{col}) as #{col}" }.join(',') + ", judge_id,
      category_id").where(["year = ?", @year]).group( :judge_id, :category_id)
    cat_results = jy_results.group_by { |jy_result| jy_result.category }
    cat_results.each do |cat, jy_results|
      jy_results.sort! { |b,a| a.total_k * a.gamma <=> b.total_k * b.gamma }
    end    
    @results = cat_results.sort_by { |cat, jy_results| cat.sequence }
  end

  def pilots
  end

end
