# no need to use rails runner
# use ruby cmd/show_flights.rb <file>
require_relative File.expand_path('../../../config/environment', __FILE__)

args = ARGV
ctlFile = args[0]
if (ctlFile)
  contest_flights = ACRO::ContestFlights.new(ctlFile)
  contest_flights.show_flights
else
  puts 'Supply the name of the contest information file'
end
