# assume loaded with rails ActiveRecord
# environment for IAC contest data application
module IAC

# this class contains methods to compute jy_results entries for
# all judges and categories in any given year
class JudgeRollups
include Log::ConfigLogger

# Accepts the year
# Computes or recomputes jy_results for every judge in every category
def self.compute_jy_results (year)
  # start_list = list all jy_result where year
  start_list = JyResult.where(:year => year).all
  Contest.where(["year(start) = ?", year]).each do |contest|
    logger.info "add #{contest.year_name} to judge rollups"
    contest.jc_results.each do |jc_result|
      category = jc_result.category
      if category
        jy_result = find_or_create_jy_result(jc_result.judge, category, year)
        if (start_list.include?(jy_result))
          jy_result.zero_reset
          start_list.delete(jy_result)
        end
        jy_result.accumulate(jc_result)
        jy_result.save
      else
        logger.error("failed category #{jc_result.category.name} for contest #{contest.year_name}")
      end
    end
  end
  # destroy any jy_result still in start_list
  start_list.each do |jy_result|
    jy_result.destroy
  end
end

#######
private
#######

def self.find_or_create_jy_result(judge, category, year)
  jy_result = JyResult.where(judge: judge, category: category, year: year).first
  if !jy_result
    jy_result = JyResult.new({
      :judge => judge,
      :category => category,
      :year => year});
    jy_result.zero_reset
  end
  jy_result
end

end #class
end #module
