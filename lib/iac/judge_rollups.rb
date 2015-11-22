# assume loaded with rails ActiveRecord
# environment for IAC contest data application

module IAC

# this class contains methods to compute jy_results entries for
# all judges and categories in any given year
class JudgeRollups

# Accepts the year
# Computes or recomputes jy_results for every judge in every category
def self.compute_jy_results (year)
  # start_list = list all jy_result where year
  start_list = JyResult.where(:year => year).all
  # all contests where year(start) == year
  Contest.where(["year(start) = ?", year]).each do |contest|
    puts "add #{contest.year_name} to judge rollups"
    contest.jc_results.each do |jc_result|
      # get category
      category = jc_result.category
      if category
        # find or create jy_result for year, category, judge
        jy_result = JyResult.find_by_judge_id_and_category_id_and_year(
          jc_result.judge.id, category.id, year)
        if !jy_result
          # can't use the "or_initialize" find because we need zero_reset
          jy_result = JyResult.new({
            :judge_id => jc_result.judge.id,
            :category_id => category.id,
            :year => year});
          jy_result.zero_reset
        elsif (start_list.include?(jy_result))
          # if in start_list, reset & remove from start_list
          jy_result.zero_reset
          start_list.delete(jy_result)
        end
        # combine jc_result
        jy_result.accumulate(jc_result)
        jy_result.save
      else
        puts("failed category #{jc_result.category.name} for contest #{contest.year_name}")
      end
    end
  end
  # destroy any jy_result still in start_list
  start_list.each do |jy_result|
    jy_result.destroy
  end
end

end #class
end #module
