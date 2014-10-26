module ACRO
class PilotFlightData

attr_accessor :pilotName
attr_accessor :flightName
attr_accessor :pilotID
attr_accessor :aircraft
attr_accessor :registration
attr_accessor :flightID
# array of judge names
attr_accessor :judges
# array of k values
attr_accessor :k_factors
# matrix of scores
# scores[j][f] is score for judge j, figure f, zero indexed
attr_accessor :scores
attr_accessor :penalty

def score(f,j)
  scores[j-1][f-1]
end

# pilot_scraper is an ACRO::PilotScraper
def process_pilot_flight(pilot_scraper)
  # get member records for pilot, judges
  @flightID = pilot_scraper.flightID
  @flightName = pilot_scraper.flightName
  @pilotID = pilot_scraper.pilotID
  @pilotName = pilot_scraper.pilotName
  @aircraft = pilot_scraper.aircraft
  @registration = pilot_scraper.registration
  @judges = pilot_scraper.judges
  @k_factors = pilot_scraper.k_factors
  @scores = []
  (1 .. @judges.size).each do |j|
    values = []
    (1 .. @k_factors.size).each do |f|
      values << pilot_scraper.score(f, j)
    end
    @scores << values
  end
  @penalty = pilot_scraper.penalty
  pfd
end

end #class
end #module
