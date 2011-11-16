# assume loaded with rails ActiveRecord
# environment for IAC contest data application
# for PfResult and PfjResult classes

require 'ranking/computer.rb'

# this class contains methods to compute rankings from results.
# It derives rankings from the scores, ranking pilots from highest
# to lowest score.
# It completes rank information for the individual pilot-judge-figure
# grades.
module IAC
class RankComputer

# Compute result values for one flight of the contest
# Accepts a flight
# Creates or updates pfj_result, pf_result
# Does no computation if there are no sequence figure k values 
# Returns the flight
def self.computeFlight(flight)
  apf = []
  flight.pilot_flights.each do |pilot_flight|
    apf << pilot_flight.results
  end
  fv = []
  afv = []
  apf.each do |pf|
    fv << pf.flight_value
    afv << pf.adj_flight_value
  end
  rv = Ranks::Computer.ranks_for(fv)
  arv = Ranks::Computer.ranks_for(afv)
  apf.each_with_index do |pf, i|
    pf.flight_rank = rv[i]
    pf.adj_flight_rank = arv[i]
  end
  flight
end

###
private
###

