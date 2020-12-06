# Script for counting the number of aircraft makes/models that have flown
# in all contests starting in 2011.

# DJM, 2020-12-06

# Filler values
UNKNOWN = 'Unknown'
unk = MakeModel.new(make: UNKNOWN, model: UNKNOWN)

# 
def u(s)
  s.strip.blank? ? UNKNOWN : s
end

# Hash to hold make/model counts
mmc = Hash.new



# Get all contests from 2011 onwards
contests = Contest.where('start >= ?', '2011-01-01')
# puts "contests: #{contests.count}"

# Get all Known flights for those contests
# Note 1: There will be fewer Known flights than contest because the DB includes canceled contests,
#         which is why we need to eliminate nil values using 'compact'.
# Note 2: Known flights have a Flight.sequence value of 1.

known_flights = contests.map{ |c| c.flights.where(sequence: 1) }.flatten.compact
# puts "known_flights: #{known_flights.count}"

# Get all the PilotFlights for those Known flights
pilot_flights = known_flights.map{ |kf| kf.pilot_flights }.flatten
# puts "pilot_flights: #{pilot_flights.count}"

# Get the Airplane record for each of those PilotFlights
airplanes = pilot_flights.map{ |pf| pf.airplane }
# puts "airplanes: #{airplanes.count}"

# Get the Make/Model record for each of those Airplanes
# Note: Some Airplane records don't have a corresponding Make/Model; in those cases,
#       we use a dummy MakeModel records with 
mms = airplanes.map{ |a| a&.make_model || unk }

mms.map{ |mm| "#{u(mm.make)},#{u(mm.model)}" }.each do |key|
  mmc[key] ||= 0
  mmc[key] += 1
end

puts "Make,Model,Count"
mmc.sort.each{ |k,v| puts "#{k},#{v}" }
