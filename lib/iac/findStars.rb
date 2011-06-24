# assume loaded with rails ActiveRecord
# environment for IAC contest data application
require 'lib/iac/constants'

# this class contains methods to find pilots who qualify for stars awards
module IAC
class FindStars
include IAC::Constants
# Examines the pilots at a contest to find any that qualify for
# stars awards.  
# Accepts the database Contest instance for examination
# Returns an Array of Hash, one per stars qualified pilot.
# Each Hash contains:
#  :given_name => first name as a string
#  :family_name => last name as a string
#  :iacID => IAC member number
#  :category => name of category for which qualified as a string
#  :aircat => 'P' or 'G' for power or glider
#  :scoresURL => URL to examine the pilot scores
#  :contest => Contest name
#  :date => Contest start date
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
    AIRPLANE_CATEGORIES.each do |aircat|
      catch (:category) do
        catFlights = Flight.find_by_sql("select * from flights 
          where contest_id = #{contest.id} and category = '#{cat}' and 
            aircat = '#{aircat}'")
        ctFMin = (iCat < 2) ? 1 : 2
        if (ctFMin <= catFlights.length) then
          flight = catFlights.first
          catPilots = flight.pilots
          # pilots of first flight sufficient; a pilot must fly every flight
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
              stars << { :given_name => pilot.given_name,
                         :family_name => pilot.family_name,
                         :iacID => pilot.iac_id,
                         :category => cat,
                         :aircat => aircat,
                         :scoresURL => make_scores_url(pilot, contest),
                         :contest => contest.name,
                         :date => contest.start
                       }
            end # catch pilot
          end # each pilot
        end # if sufficient flights
      end # catch category
    end # each aircat 
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
      ctBlw5 += 1 if 0 <= s && s < 50
      throw :pilot if maxBlw5 < ctBlw5
    end
  end
end

# create a URL for the scores
# we don't have ActiveRouting path helpers, so we punt on this
# and build it with extrinsic knowledge of the resource path
def self.make_scores_url(pilot, contest)
  "http://www.iaccdb.org/pilots/#{pilot.id}/scores/#{contest.id}"
end

end #class
end #module
