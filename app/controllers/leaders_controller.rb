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

  def regionals
    @year = params[:year] || Time.now.year
    @years = RegionalPilot.select("distinct year").all.collect{|rp| rp.year}.sort{|a,b| b <=> a}
    region_pilots = RegionalPilot.includes(:category, :pilot, :pc_results).joins(:region_contest).where(['year = ?', @year]).group('regional_pilot_id').having('count(distinct pc_result_id) > 1')
    sorted_regions = {}
    @region_categories = {}
    region_results = region_pilots.group_by { |rp| rp.region }
    region_results.each do |region, rp|
      cat_results = rp.group_by { |rpc| rpc.category }
      cat_results.each do |cat, rpc|
        puts "Category #{cat} region #{region} has region_pilots: #{rpc}"
        rpc.sort! { |a,b| a.rank <=> b.rank }
      end    
      sorted_regions[region] = cat_results.sort_by { |cat, rpc| cat.sequence }
      @region_categories[region] = cat_results.keys
    end
    @results = sorted_regions.sort
    @regions = sorted_regions.keys
  end

end
