# read into the database pilot results from 
#   extracted CategoryResult YAML files
module ACRO
class ResultsPatch

def initialize(control_file)
  @contest_info = ControlFile.new(control_file)
  @participant_list = ParticipantList.new
  @participant_list.read(@contest_info.data_directory)
  @results_list = ResultsList.new(control_file)
  @results_list.read_from_file
  @rank_computer = IAC::RankComputer.instance
end

def patch_flight_results
  puts "Patching results into contest, #{@contest_info.name}"
  pcs = []
  @d_contest = Contest.find(@contest_info.contest_id)
  @results_list.list.each do |rfr|
    begin
      puts "Results patch processing file, #{rfr.file_name}"
      category_results = YAML.load_file(File.join(@contest_info.data_directory, rfr.file_name))
      process_category(rfr, category_results)
    rescue Exception => e
      puts "\nSomething went wrong with #{rfr.file_name}:"
      puts e.message
      puts e.backtrace.join("\n")
      pcs << rfr.file_name
    end
  end
  pcs
end

#pilot_flight_data is an ACRO::PilotScraper
def process_category(rfr, category_results)
  cat_flights = category_results.flight_names
  puts "category is #{category_results.description}"
  d_category = nil
  rfr.flights.each do |flight|
    puts "flight is #{flight.flight_name} id #{flight.flight_id}"
    f = cat_flights.index(flight.flight_name)
    id = flight.flight_id.to_i
    if f && id != 0
      d_flight = Flight.find(id)
      if d_category && d_flight.category.id != d_category.id
        # this is a safety check to constrain flight id mistake
        raise "Flight #{d_flight.displayName} is not same category as the others"
      else
        d_category ||= d_flight.category
      end
      if d_flight.contest_id == @d_contest.id
          patch_pilot_results_for_category_flight(category_results, f, d_flight)
          d_flight.sequence = flight.sequence
          d_flight.save!
      else
        # this is a safety check to constrain flight id mistake to a single contest
        raise "Flight #{d_flight.displayName} is not a flight of #{@d_contest.name}"
      end
    else
      raise 
        "Missing ID or flight match for #{category_results.description} #{flight.flight_name}"
    end
  end
  if d_category
    patch_pilot_results_for_category(category_results, d_category)
  else
    raise "Cannot determine category for #{category_results.description}"
  end
end

###
private
###

def patch_pilot_results_for_category_flight(category_results, f, d_flight)
  category_results.pilots.each_with_index do |pilot, p|
    d_pilot = find_member(pilot)
    d_pf = d_flight.pilot_flights.where(pilot_id: d_pilot.id).first
    if d_pf
      d_pfr = d_pf.pf_results.first
      if d_pfr
        d_pfr.adj_flight_value = category_results.flight_results[p][f]
        d_pfr.save!
        puts "#{pilot} in #{d_flight.displayName} scored #{d_pfr.adj_flight_value}"
      else
        raise "Failed to find result for pilot #{pilot} in flight #{d_flight.displayName}"
      end
    else
      # this isn't necessarily a failure, but a warning
      puts "WARN: Failed to find flight for pilot #{pilot} in flight #{d_flight.displayName}"
    end
  end
  @rank_computer.compute_flight_rankings(d_flight)
end

def patch_pilot_results_for_category(category_results, d_category)
  category_results.pilots.each_with_index do |pilot, p|
    d_pilot = find_member(pilot)
    d_pcr = @d_contest.pc_results.where(category: d_category, 
      pilot_id: d_pilot.id).first
    d_pcr.category_value = category_results.category_results[p]
    d_pcr.save!
    puts "#{pilot} in #{category_results.category_name} scored #{d_pcr.category_value}"
  end
  cat_rollups = CategoryRollups.new(@d_contest, d_category)
  cat_rollups.compute_pilot_rankings
end

def find_member(name)
  participant = @participant_list.participant(name)
  if participant
    Member.find(participant.db_id)
  else
    raise Exception.new("Missing participant to member mapping for #{name}")
  end
end

end #class
end #module
