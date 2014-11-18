module IAC
class CollegiateTeamComputer

class Result
  attr_accessor :total
  attr_accessor :total_possible
  attr_accessor :combination
  attr_accessor :qualified

  def initialize
    @total = 0.0
    @total_possible = 0
    @combination = []
    @qualified = false
  end

  def self.dup(result)
    dup = Result.new
    dup.total = result.total
    dup.total_possible = result.total_possible
    dup.combination = Array.new(result.combination)
    dup.qualified = result.qualified
    dup
  end

  def update(pc_result)
    @total += pc_result.category_value
    @total_possible += pc_result.total_possible
    @combination << pc_result
  end

  def value
    @total_possible != 0 ? @total / @total_possible : 0
  end
end

# pilot_contests is hash pilot => pc_results
def initialize(pilot_contests)
  @pilot_contests = pilot_contests
  @pilots = pilot_contests.keys
end

# For each pilot participating in Sportsman or above
#   For each of that pilot's non-Primary results
#      For each combination of up to two other pilots
#         For each combination of those two pilot's results
#           Keep the best ratio of total points earned over possible
#           Track which flights compose the combination
# If no non-Primary results
#    For each combination of up to three pilots
#       For each combination of those pilot's results
#         Keep the best ratio of total points earned over possible
#         Track which flights compose the combination
# Return result:
#  :total_possible => integer
#  :total => decimal
#  :combination => array of pc_result
def compute_result
  initialize_counts
  @best_result = Result.new
  @best_result.qualified = is_qualified?
  compute_best_result_p(@pilots, 3, @best_result, 0 < @non_primary_participant_occurrence_count)
  @best_result
end

###
private
###

# Count of pilots participating is three or more and
# Three contests with three pilots and
# Three contests with at least one non-Primary pilot
def is_qualified?
    3 <= @non_primary_participant_occurrence_count &&
    3 <= @three_or_more_pilot_occurrence_count
end

# find best result combination over pilots not yet used
# unused_pilots: array of pilot not already incorporated
# pilots_needed: count of additional pilots needed for a solution
# cur_result: current accumulated result of pilot flights used so far
# need_non_primary: true if a non-primary result is needed in the solution
def compute_best_result_p(unused_pilots, pilots_needed, cur_result, need_non_primary)
  if (pilots_needed == 0 || unused_pilots.empty?)
    if @best_result.value < cur_result.value
      @best_result = cur_result
    end
  else
    unused_pilots.each do |pilot|
      compute_best_result_pc(pilot, unused_pilots - [pilot], pilots_needed - 1, 
        cur_result, need_non_primary)
    end
  end
end

# find best result combination with results for pilot
# pilot: current pilot candidate
# unused_pilots: array of pilot not already incorporated
# pilots_needed: count of additional pilots needed for a solution
# cur_result: current accumulated result of pilot flights used so far
# need_non_primary: true if a non-primary result is needed in the solution
def compute_best_result_pc(pilot, unused_pilots, pilots_needed, cur_result, need_non_primary)
  pilot_results = @pilot_contests[pilot]
  pilot_results.each do |pc_result|
    if !need_non_primary || !pc_result.category.is_primary
      new_result = Result.dup(cur_result)
      new_result.update(pc_result)
      compute_best_result_p(unused_pilots, pilots_needed, new_result, false)
    end
  end
end

def initialize_counts
  contests_properties = gather_contest_properties(@pilot_contests)
  @non_primary_participant_occurrence_count = 0
  @three_or_more_pilot_occurrence_count = 0
  contests_properties.each do |contest|
    @non_primary_participant_occurrence_count += 1 if contest[:has_non_primary]
    @three_or_more_pilot_occurrence_count += 1 if 3 <= contest[:pilot_count]
  end
end

# pilot_contests is hash of pilot (member)  => [ array of pc_result ]
# return an array of hashes, one for each unique contest found in pilot_contests
# each hash contains keys:
#   :has_non_primary boolean true if one pilot flew the contest not in Primary
#   :pilot_count integer count of pilots who flew in the contest
def gather_contest_properties(pilot_contests)
  contest_props = {}
  pilot_contests.each_pair do | pilot, pc_results |
    pc_results.each do | pc_result |
      contest = pc_result.contest
      props = contest_props[contest] 
      if !props
        props = { :has_non_primary => false, :pilot_count => 0 }
        contest_props[contest] = props
      end
      props[:pilot_count] += 1
      if !pc_result.category.is_primary
        props[:has_non_primary] = true
      end
    end
  end
  contest_props.values
end

end
end
