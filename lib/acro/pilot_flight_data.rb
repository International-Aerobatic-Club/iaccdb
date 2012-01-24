module ACRO
class PilotFlightData

attr_accessor :pilotName
attr_accessor :flightName
attr_accessor :pilotID
attr_accessor :flightID
# array of judge names
attr_accessor :judges
# array of k values
attr_accessor :k_factors
# matrix of scores
# scores[j][f] is score for judge j, figure f, zero indexed
attr_accessor :scores
attr_accessor :penalty

end #class
end #module
