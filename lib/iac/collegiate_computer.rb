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
  CollegiateResult.where(:year => @year).each do |team|
    puts "Computing #{team}"
    pilots = team.members.all # array of pilot members
    pilot_contests = {}
    pilots.each do |pilot|
      pilot_contests[pilot] = pilot.contests(@year)
    end
    compute_best_result(team, CollegiateTeamComputer.new(pilot_contests))
    team.save
    puts "Computed #{team}"
  end
end

# Compute the year's individual results
def recompute_individual
  puts 'Individual to be developed'
end

###
private
###

# Sets team points and points_possible
# Sets team pc_results list of up to three used for points and points_possible
def compute_best_result(team, ctc)
  result = ctc.compute_result
  team.qualified = result.qualified
  team.points = result.total
  team.points_possible = result.total_possible
  puts "result combination has #{result.combination.join(',')}"
  puts 'TBD patch pc_results on team with result[:combination]'
end

end
end
