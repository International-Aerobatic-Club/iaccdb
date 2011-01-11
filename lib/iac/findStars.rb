# assume loaded with rails ActiveRecord
# environment for IAC contest data application
require 'lib/iac/constants'

# this class contains methods to find pilots who qualify for stars awards
module IAC
class FindStars

# Examines the pilots at a contest to find any that qualify for
# stars awards.  
# Accepts the database Contest instance for examination
# Returns an Array of Hash, one per stars qualified pilot.
# Each Hash contains:
#  :name => first and last name as a string
#  :iacID => IAC member number
#  :category => name of category qualified as a string
#  :scoresURL => URL to examine the pilot scores
# Returns an empty array if there are no qualifying pilots
#
# The algorithm is based on the rules for stars qualification from
#   Appendix 5 of the IAC Official Contest Rules
#  foreach category
#    determine number of flights
#    if adequate (one for Pri, Spn; two for Imdt, Adv, Unl)
#    for each pilot
#      for each flight
#        if not three judges, break category (minimum three judges)
#        determine max judges scoring below five (zero if three judges, else one)
#        for each figure
#          count judges scoring below five, break pilot if max exceeded
#        if you get here, the pilot qualified
def self.findStars (contest)
  stars = []
  CONTEST_CATEGORIES.each_with_index do |cat, iCat|
    catch (:category) do
      catFlights = contest.flights.find_all_by_category(cat)
      # TODO problem if both power and glider in category; must distinguish
      ctFMin = (iCat < 2) ? 1 : 2
      if (ctFMin <= catFlights.length) then
        catPilots = catFlights[0].pilots
        # pilots of first flight sufficient because a pilot must fly every flight
        catPilots.each do |pilot|
          catch (:pilot) do
            catFlights.each do |flight|
              # if not three judges, break category (minimum three judges)
              ctJ = flight.count_judges
              throw :category if ctJ < 3
              maxBlw5 = (ctJ == 3) ? 0 : 1
              pilotFlight = flight.pilot_flights.find_by_pilot_id(pilot)
              test_pilot_flight stars, pilotFlight, maxBlw5
            end # each flight
            stars << { :name => pilot.name,
                       :iacID => pilot.iac_id,
                       :category => cat,
                       :scoresURL => make_scores_url(pilot, contest)
                     }
          end # catch pilot
        end # each pilot
      end # if sufficient flights
    end # catch category
  end # each category
  stars
end

###
private
###

# check score from each judge for each figure 
# throws :pilot if number of scores below five on a figure exceeds maxBlw5
# adds a Hash to Array stars if all figures pass
def self.test_pilot_flight(stars, pilotFlight, maxBlw5)
  pfScores = pilotFlight.gatherScores
  pfScores.each do |f|
    ctBlw5 = 0
    f.each do |s|
      ctBlw5 += 1 if s < 50
      throw :pilot if maxBlw5 < ctBlw5
    end
  end
end

# create a URL for the scores
# we don't have ActiveRouting path helpers, so we punt on this
# and build it with extrinsic knowledge of the resource path
def self.make_scores_url(pilot, contest)
  "http://www.iacusn.org/cdb/pilots/#{pilot.id}/scores/#{contest.id}"
end

end #class
end #module
