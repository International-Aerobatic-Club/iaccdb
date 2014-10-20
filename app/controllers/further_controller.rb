class FurtherController < ApplicationController
  def participation
    judge_counts = JyResult.includes(:category).select(
        'count(distinct(judge_id)) as count, category_id , year'
      ).group(:category_id, :year)
    @cat_year_judge_count = judge_counts.group_by { |count| count.category }
    @cat_year_judge_count.each do |key, ac| 
      @cat_year_judge_count[key] = ac.group_by { |count| count.year }
    end
    yy = judge_counts.collect { |jy_result| jy_result.year }
    @years = Set.new(yy)

    pilot_counts = PcResult.select(
        'count(distinct(pilot_id)) as count, c_result_id'
      ).group(:c_result_id)
    @cat_year_pilot_count = pilot_counts.group_by { |pcr| pcr.category }
    @cat_year_pilot_count.each do |key, apcr| 
      a_counts = apcr.group_by { |pcr| pcr.contest.year }
      a_counts.each do |year, aapcr|
        count = aapcr.inject(0) { |count, pcr| count += pcr.count }
        aapcr[0].count = count
        a_counts[year] = aapcr[0,1]
      end
      @cat_year_pilot_count[key] = a_counts
    end
    yy = pilot_counts.collect { |pf| pf.contest.year }
    @years.merge(yy)
    @categories = Category.order(:sequence)
  end
end
