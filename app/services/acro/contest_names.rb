# read pilot and judge names from extracted PilotFlightData YAML files
# read member records from extracted member_list.txt tab separated value file
# interactively select member record identifiers to match the names
# output the mapping from name to member record identifier as a lookup table
# for verification, include the member record given and family names with the identifer
# input is name of control file that identifies the contest
# writes to, and REPLACES the participant YAML file in same directory as the control file
# see contest_extractor.rb
require 'set'

module ACRO
class ContestNames

def initialize(control_file)
  @contest_info = ControlFile.new(control_file)
  @member_list = MemberList.new(@contest_info.data_directory)
end

def match_names_to_records
  puts "Match names to member records for #{@contest_info.name}"
  name_set = extract_names
  participant_list = ParticipantList.new
  participant_list.read(@contest_info.data_directory)
  name_set.each do |name|
    prior_selection = participant_list.participant(name)
    member_record = match_name_to_record(name, prior_selection)
    participant_list.add(name, member_record)
  end
  participant_list.write(@contest_info.data_directory)
end

###
private
###

def match_name_to_record(name, prior)
  parts = name.split(' ')
  @given = parts.shift
  @family = parts.join(' ')
  select_and_return_member(initials_strategy, prior)
end

def display_name
  "#{@given} #{@family}"
end

def select_and_return_member(result, prior)
  selected = nil
  searching = true
  while searching
    puts "#{display_name}"
    result.sort! { |a,b| a['family_name'] <=> b['family_name'] } if result
    result.unshift(prior.as_member) if prior
    write_candidates(result, prior)
    puts "Select record to match '#{display_name}'"
    puts 'You type a number or a, b, c, d, N, ?'
    input = $stdin.gets
    sel = input ? input.to_i : 0
    if sel != 0 && result != nil && sel <= result.count
      selected = result[sel-1]
      searching = false
    elsif input != nil
      case input.strip[0]
      when 'a'
        result = family_name_strategy
      when 'b'
        result = leading_two_strategy
      when 'c'
        result = initials_strategy
      when 'd'
        result = family_name_two_strategy
      when 'N'
        searching = false
      when '?'
        puts 'a: match family (last) name'
        puts 'b: match first two characters of given and family name'
        puts 'c: match first initial of given and family name'
        puts 'd: match first two characters of family (last) name'
        puts 'N: no matching entries; this is a new name'
        puts 'type a number to select the member listed with the number'
      end
    else
      searching = false
    end
  end
  selected
end

def write_candidates(result, prior)
  if (result && !result.empty?)
    i = 1;
    result.each do |r|
      printf (prior && i == 1) ? '*' : ' '
      puts "#{i}: #{r['given_name']} #{r['family_name']} #{r['iac_id']}"
      i += 1
    end
  else
    puts "No matches for #{display_name}"
  end
end

def initials_strategy
  puts 'initials strategy'
  @member_list.by_fi_li(@given, @family)
end

def leading_two_strategy
  puts 'leading two initials strategy'
  @member_list.by_f2_l2(@given, @family)
end

def family_name_strategy
  puts 'family (last) name strategy'
  @member_list.by_last(@family)
end

def family_name_two_strategy
  puts 'family (last) name first two character strategy'
  @member_list.by_l2(@family)
end

def extract_names
  name_set = Set::new
  @contest_info.pilot_flight_result_files.each do |f|
    begin
      pilot_flight_data = YAML.load_file(f)
      name_set.merge(pilot_flight_names(pilot_flight_data))
    rescue Exception => e
      puts "\nSomething went wrong with #{f}:"
      puts e.message
      puts e.backtrace.each.join("\n")
    end
  end
  name_set
end

#pilot_flight_data is an ACRO::PilotScraper
def pilot_flight_names(pilot_flight_data)
  # get member records for pilot, judges
  names = pilot_flight_data.judges
  names << pilot_flight_data.pilotName
end

end #class
end #module
