module IAC
class CollegiateTeamComputer

class Result
  attr_accessor :total
  attr_accessor :total_possible
  attr_accessor :combination
  attr_accessor :qualified
  attr_accessor :has_non_primary

  def initialize
    @total = 0.0
    @total_possible = 0
    @combination = []
    @qualified = false
    @has_non_primary = false
  end

  def self.dup(result)
    dup = Result.new
    dup.total = result.total
    dup.total_possible = result.total_possible
    dup.combination = Array.new(result.combination)
    dup.qualified = result.qualified
    dup.has_non_primary = result.has_non_primary
    dup
  end

  def update(pc_result)
    self.total += pc_result.category_value
    self.total_possible += pc_result.total_possible
    self.combination << pc_result
    self.has_non_primary = self.has_non_primary || !pc_result.category.is_primary
  end

  def value
    self.total_possible != 0 ? self.total / self.total_possible : 0
  end

  def <(other)
    self.value < other.value
  end

  def to_s
    s = "#{sprintf('%0.2f', value * 100.0)}\n"
    combination.each do |c|
      s << "\t#{c.pilot.iac_id} #{c.contest.name}\n"
    end
    s
  end
end

# pilot_contests is hash pilot => pc_results
def initialize(pilot_contests)
  @pilot_contests = pilot_contests
  @pilots = @pilot_contests.keys
  # disregard pilots with no contest participation
  @pilots.delete_if { |pilot| @pilot_contests[pilot].size == 0 }
  initialize_counts
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
  @best_result = Result.new
  pilot_count = @pilots.size
  combination_size = 3 < pilot_count ? 3 : pilot_count
  compute_best_result_p(@pilots, combination_size, @best_result)
  @best_result.qualified = @is_qualified
  @best_result
end

###
private
###

# find best result combination over pilots not yet used
# unused_pilots: array of pilot not already incorporated
# pilots_needed: count of additional pilots needed for a solution
# cur_result: current accumulated result of pilot flights used so far
def compute_best_result_p(unused_pilots, pilots_needed, cur_result)
  if (pilots_needed == 0 || unused_pilots.empty?)
    if @best_result < cur_result &&
        (!@is_qualified || cur_result.has_non_primary)
      @best_result = cur_result
    end
  else
    (0 .. unused_pilots.size - pilots_needed).each do |i|
      compute_best_result_pc(unused_pilots[i],
        unused_pilots[i+1 .. unused_pilots.size],
        pilots_needed - 1, 
        cur_result)
    end
  end
end

# find best result combination with results for pilot
# pilot: current pilot candidate
# unused_pilots: array of pilot not already incorporated
# pilots_needed: count of additional pilots needed for a solution
# cur_result: current accumulated result of pilot flights used so far
def compute_best_result_pc(pilot, unused_pilots, pilots_needed, cur_result)
  pilot_results = @pilot_contests[pilot]
  pilot_results.each do |pc_result|
    new_result = Result.dup(cur_result)
    new_result.update(pc_result)
    compute_best_result_p(unused_pilots, pilots_needed, new_result)
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

  # Count of pilots participating is three or more and
  # Three contests with three pilots and
  # Three contests with at least one non-Primary pilot
  @is_qualified =
    3 <= @non_primary_participant_occurrence_count &&
    3 <= @three_or_more_pilot_occurrence_count
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
