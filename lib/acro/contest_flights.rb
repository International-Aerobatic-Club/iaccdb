# read flight names from extracted PilotFlightData YAML files
# show category, class, flight for each flight name
# use to verify correct classification and assignment of the flights
# ACRO uses some unusual flight identifiers
# see contest_extractor.rb
require 'set'

module ACRO
class ContestFlights
  include FlightIdentifier
  def initialize(control_file)
    @contest_info = ControlFile.new(control_file)
  end

  def show_flights
    extract_flights.each do |flight|
      cat = detect_flight_category(flight)
      aircat = detect_flight_aircat(flight)
      sequence = detect_flight_name(flight)
      puts "'#{flight}', #{cat}, #{aircat}, #{sequence}"
    end
  end

private

  def extract_flights
    flight_set = Set::new
    @contest_info.pilot_flight_result_files.each do |f|
      begin
        pilot_flight_data = YAML.load_file(f)
        flight_set << pilot_flight_data.flightName
      rescue Exception => e
        puts "\nSomething went wrong with #{f}:"
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
    flight_set
  end
end
end
