# Script to count the number times a given make/model pair competed starting in 2011
# DJM, 2020-12-06

UNKNOWN = 'Unknown'
unk = MakeModel.new(make: UNKNOWN, model: UNKNOWN)

def u(s)
  s.strip.blank? ? UNKNOWN : s
end

mmc = Hash.new

contests = Contest.where('start >= ?', '2011-01-01')
# puts "contests: #{contests.count}"

flights = contests.map{ |c| c.flights.find_by_sequence(1) }.compact
# puts "flights: #{flights.count}"

pilot_flights = flights.map{ |f| f.pilot_flights }.flatten
# puts "pilot_flights: #{pilot_flights.count}"

airplanes = pilot_flights.map{ |pf| pf.airplane }
# puts "airplanes: #{airplanes.count}"

mms = airplanes.map{ |a| a&.make_model || unk }

mms.map{ |mm| "#{u(mm.make)},#{u(mm.model)}" }.each do |key|
  mmc[key] ||= 0
  mmc[key] += 1
end

puts "Make,Model,Count"
mmc.sort.each{ |k,v| puts "#{k},#{v}" }
