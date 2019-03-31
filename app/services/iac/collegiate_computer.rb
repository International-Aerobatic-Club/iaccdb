# Computes team and individual results and leaves them in the database
module IAC
class CollegiateComputer

def initialize (year)
  @year = year
end

def recompute
  recompute_team
  recompute_individual
end

# Compute the year's team result
# For each collegieate team
#   Extract list of pilots
#   Extract list of contests for each pilot
#   Determine qualification
#   Determine best score combination
def recompute_team
  teams = CollegiateResult.where(:year => @year).all
  teams.each do |team|
    ctc = CollegiateTeamComputer.new(team.pilot_contests)
    result = ctc.compute_result
    team.qualified = result.qualified
    team.points = result.total
    team.points_possible = result.total_possible
    team.update_results(result.combination)
    team.save!
  end
  RankComputer.compute_result_rankings(teams)
end

# Compute the year's individual results
def recompute_individual
  cic = CollegiateIndividualComputer.new(@year)
  cic.recompute
  results = CollegiateIndividualResult.where(:year => @year).all
  RankComputer.compute_result_rankings(results)
end

def self.non_comp_allowed?(year)
  2018 < year
end

# find PcResult records for given pilot and year
# filter or do not filter according to HC (competitive)
def self.pilot_results(pilot, year)
  results = if (non_comp_allowed?(year))
    PcResult.non_comp_allowed
  else
    PcResult.competitive
  end
  results.joins(:contest).where(
    "pilot_id = ? and year(contests.start) = ?", pilot.id, year).all
end

###
private
###

# Sets team qualified boolean result
# Count of pilots participating is three or more and
# Three contests with three pilots and
# Three contests with at least one non-Primary pilot
def compute_qualification(team, pilots, pilot_contests)
  if 3 <= pilots.size
    contests_properties = gather_contest_properties(pilot_contests)
    non_primary_participant_occurrence_count = 0
    three_or_more_pilot_occurrence_count = 0
    contests_properties.each do |contest|
      non_primary_participant_occurrence_count += 1 if contest[:has_non_primary]
      three_or_more_pilot_occurrence_count += 1 if 3 <= contest[:pilot_count]
    end
    team.qualified = 3 <= non_primary_participant_occurrence_count &&
                     3 <= three_or_more_pilot_occurrence_count
  else
    team.qualified = false
  end
end

# pilot_contests is hash of pilot (member)  => [ array of pc_result ]
# return an array of hashes, one for each unique contest found in pilot_contests
# each hash contains keys:
#   :has_non_primary boolean true if one pilot flew the contest not in Primary
#   :pilot_count integer count of pilots who flew in the contest
def gather_contest_properties(pilot_contests)
  []
end

# Sets team points and points_possible
# Sets team pc_results list of up to three used for points and points_possible
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
def compute_best_score(team, pilots, pilot_contests)
  combination = []
  total = 0.0
  total_possible = 0
  puts 'compute_score TBD'
end

end
end
