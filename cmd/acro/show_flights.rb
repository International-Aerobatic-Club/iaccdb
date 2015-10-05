# use rails runner cmd/show_flights.rb <contest info file>
# lists the flights found in the contest extracted .yml files

args = ARGV
ctlFile = args[0]
if (ctlFile)
  contest_flights = ACRO::ContestFlights.new(ctlFile)
  contest_flights.show_flights
else
  puts 'Supply the name of the contest information file'
end

