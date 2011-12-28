require 'acro/pilotScraper'
require 'iac/constants'

# scrape pilot scores from ACRO produced web site files
module ACRO
class ContestScraper

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

def scrapeContest
  pcs = []
  files.each do |f|
    begin
      pScrape = ACRO::PilotScraper.new(f)
      process_pilotFlight(pScrape)
    rescue Exception => e
      puts "\nSomething went wrong with #{f}:"
      puts e.message
      e.backtrace.each { |l| puts l }
      pcs << f
    end
  end
  pcs
end

def files
  pfs = @pDir.find_all { |name| name =~ /^pilot_p\d{3}s\d\d\.htm$/ }
  pfs.collect { |fn| File.join(@pDir.path, fn) }
end

#pScrape is an ACRO::PilotScraper
def process_pilotFlight(pScrape)
  # get member records for pilot, judges
  judge_members = pScrape.judges.collect { |j| find_member(j) }
  pilot_member = find_member(pScrape.pilotName)
  # maintain mapping from flight id to flight record
  flight = @flights[pScrape.flightID]
  if !flight
    flight = create_or_replace_pilot_flight(pScrape)
  end
  # add the scores and figure k's
  pilot_flight = flight.pilot_flights.build(:pilot => pilot_member)
  kays = pScrape.k_factors
  (1 .. judge_members.size).each do |j|
    values = []
    judge = judge_members[j-1]
    judge_team = @judge_teams[judge]
    if !judge_team
      judge_team = make_judge_team(judge)
    end
    (1 .. kays.size).each do |f|
      values << pScrape.score(f, j)
    end
    pilot_flight.scores.build(:judge => judge_team, :values => values)
  end
  pilot_flight.sequence = Sequence.find_or_create(kays)
  pilot_flight.penalty_total = pScrape.penalty
  pilot_flight.save
end

###
private
###

def create_or_replace_pilot_flight(pScrape)
  category = detect_flight_category(pScrape.flightName)
  name = detect_flight_name(pScrape.flightName)
  aircat = detect_flight_aircat(pScrape.flightName)
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
    @flights[pScrape.flightID] = flight
  else
    throw ArgumentError.new(
      "Unable category, name or aircat for flight, #{pScrape.flightName}")
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
    elsif /Sport/i =~ description || /Spn/i =~ description
      cat = 'Sportsman'
    elsif /Adv/i =~ description
      cat = 'Advanced'
    elsif /Imdt/i =~ description || /Intmdt/i =~ description
      cat = 'Intermediate'
    elsif /Unl/i =~ description
      cat = 'Unlimited'
    end
  end
  cat
end

def detect_flight_name(description)
  name = nil
  IAC::Constants::FLIGHT_NAMES.each do |fltName|
    name = fltName if Regexp.new(fltName, 'i') =~ description
  end
  name
end

def detect_flight_aircat(description)
  aircat = nil
  if /Power/i =~ description
    aircat = IAC::Constants::POWER_CATEGORY
  elsif /Glider/i =~ description
    aircat = IAC::Constants::GLIDER_CATEGORY
  end 
  aircat
end

end #class
end #module
