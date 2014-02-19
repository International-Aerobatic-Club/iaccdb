class LeadersController < ApplicationController
  def judges
    @year = params[:year] || Time.now.year
    @years = JyResult.select("distinct year").all.collect{|jy_result|
    jy_result.year}.sort{|a,b| b <=> a}
    jy_results = JyResult.includes(:category, :judge).select(
      [:pilot_count, :sigma_ri_delta, :con, :dis, :minority_zero_ct,
       :minority_grade_ct, :pair_count, :ftsdx2, :ftsdy2, :ftsdxdy, :sigma_d2,
       :total_k, :figure_count, :flight_count, :ri_total].collect { |col|
      "sum(#{col}) as #{col}" }.join(',') + ", judge_id,
      category_id").where(["year = ?", @year]).group( :judge_id, :category_id)
    cat_results = jy_results.group_by { |jy_result| jy_result.category }
    crop_results = {}
    cat_results.each do |cat, jy_results|
      if (@year.to_i < 2013) then
        jy_results.sort! { |b,a| a.con <=> b.con }
      else
        jy_results.sort! { |b,a| (a.con - a.dis) <=> (b.con - b.dis) }
      end
      crop_results[cat] = jy_results.first(10)
    end    
    @results = crop_results.sort_by { |cat, jy_results| cat.sequence }
  end

  def pilots
  end

end
