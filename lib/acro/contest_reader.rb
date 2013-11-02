#require 'acro/pilot_flight_data'

# read into the database pilot scores from 
#   extracted PilotFlightData YAML files
# see contest_extractor.rb
module ACRO
class ContestReader

attr_reader :dContest 
attr_reader :pDir 

def initialize(ctlFile)
  cData = YAML.load_file(ctlFile)
  cName = checkData(cData, 'contestName')
  cDate = checkData(cData, 'startDate')
  @dContest = Contest.where(:name => cName, :start => cDate).first
  if !@dContest then
    @dContest = Contest.new(
      :name => cName,
      :city => checkData(cData, 'city'),
      :state => checkData(cData, 'state'),
      :start => cDate,
      :chapter => cData['chapter'],
      :director => checkData(cData, 'director'),
      :region => cData['region'])
    @dContest.save
  end
  @pDir = Dir.new(File.dirname(ctlFile))
  @flights = {}
  @judge_teams = {}
end

def read_contest
  puts "Contest reader processing contest, #{@dContest.year_name}"
  pcs = []
  files.each do |f|
    begin
      puts "Contest reader processing file, #{f}"
      pilot_flight_data = YAML.load_file(f)
      process_pilotFlight(pilot_flight_data)
    rescue Exception => e
      puts "\nSomething went wrong with #{f}:"
      puts e.message
      puts e.backtrace.each.join("\n")
      pcs << f
    end
  end
  pcs
end

def files
  pfs = @pDir.find_all { |name| name =~ /^pilot_p\d{3}s\d\d\.htm.yml$/ }
  pfs.collect { |fn| File.join(@pDir.path, fn) }
end

#pilot_flight_data is an ACRO::PilotScraper
def process_pilotFlight(pilot_flight_data)
  # get member records for pilot, judges
  judge_members = pilot_flight_data.judges.collect { |j| find_member(j) }
  pilot_member = find_member(pilot_flight_data.pilotName)
  # maintain mapping from flight id to flight record
  flight = @flights[pilot_flight_data.flightID]
  if !flight
    flight = create_or_replace_pilot_flight(pilot_flight_data)
  end
  # add the scores and figure k's
  pilot_flight = flight.pilot_flights.build(:pilot => pilot_member)
  kays = pilot_flight_data.k_factors
  (1 .. judge_members.size).each do |j|
    values = []
    judge = judge_members[j-1]
    judge_team = @judge_teams[judge]
    if !judge_team
      judge_team = make_judge_team(judge)
    end
    (1 .. kays.size).each do |f|
      values << pilot_flight_data.score(f, j)
    end
    pilot_flight.scores.build(:judge => judge_team, :values => values)
  end
  pilot_flight.sequence = Sequence.find_or_create(kays)
  pilot_flight.penalty_total = pilot_flight_data.penalty
  pilot_flight.save
end

###
private
###

def create_or_replace_pilot_flight(pilot_flight_data)
  category = detect_flight_category(pilot_flight_data.flightName)
  name = detect_flight_name(pilot_flight_data.flightName)
  aircat = detect_flight_aircat(pilot_flight_data.flightName)
  # create flight record first time id seen, infer category and flight
  if (category && name && aircat)
    Flight.where(
      :contest_id => @dContest, 
      :name => name, 
      :category => category, 
      :aircat => aircat).destroy_all
    flight = @dContest.flights.build(
     :name => name,
     :category => category,
     :aircat => aircat, 
     :sequence => 0)
    flight.save
    @flights[pilot_flight_data.flightID] = flight
  else
    throw ArgumentError.new(
      "Unable category, name or aircat for flight, #{pilot_flight_data.flightName}")
  end
  flight
end

def make_judge_team(judge)
  judge_team = Judge.new(:judge => judge)
  @judge_teams[judge] = judge_team
  judge_team.save
  judge_team
end

def find_member(name)
  parts = name.split(' ')
  given = parts[0]
  parts.shift
  family = parts.join(' ')
  Member.find_or_create_by_name(0, given, family)
end

def checkData(cData, field)
  datum = cData[field]
  if !datum
    raise ArgumentError, "Missing data for contest #{field}"
  end
  datum
end

def detect_flight_category(description)
  cat = nil
  if /Four/i =~ description || /Minute/i =~ description
    cat = 'Four Minute' 
  else
    IAC::Constants::CONTEST_CATEGORIES.each do |catName|
      cat = catName if Regexp.new(catName, 'i') =~ description
    end
  end
  if !cat
    if /Pri/i =~ description
      cat = 'Primary'
    elsif /Sport|Standard/i =~ description || /Spn/i =~ description
      cat = 'Sportsman'
    elsif /Adv/i =~ description
      cat = 'Advanced'
    elsif /Imdt/i =~ description || /Intmdt/i =~ description
      cat = 'Intermediate'
    elsif /Unl/i =~ description
      cat = 'Unlimited'
    elsif /Minute|Four/i =~ description
      cat = 'Four Minute Free'
    end
  end
  cat
end

def detect_flight_name(description)
  name = nil
  if /Team/i =~ description
    name = 'Team Unknown' 
  elsif /#1/ =~ description
    name = 'Flight 1'
  elsif /#2/ =~ description
    name = 'Flight 2'
  elsif /#3/ =~ description
    name = 'Flight 3'
  else
    IAC::Constants::FLIGHT_NAMES.each do |fltName|
      name = fltName if Regexp.new(fltName, 'i') =~ description
    end
  end
  name
end

def detect_flight_aircat(description)
  aircat = nil
  if /Power|Four|Minute|Primary/i =~ description
    aircat = IAC::Constants::POWER_CATEGORY
  elsif /Glider/i =~ description
    aircat = IAC::Constants::GLIDER_CATEGORY
  end 
  aircat
end

end #class
end #module
