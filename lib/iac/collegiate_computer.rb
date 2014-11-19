# Computes team and individual results and leaves them in the database
module IAC
class CollegiateComputer

def initialize (year)
  @year = year
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
    team.save
  end
  RankComputer.compute_result_rankings(teams)
end

# Compute the year's individual results
def recompute_individual
  puts 'Individual to be developed'
end

end
end
