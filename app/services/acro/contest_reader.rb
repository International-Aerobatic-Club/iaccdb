# read into the database pilot scores from 
#   extracted PilotFlightData YAML files
# see contest_extractor.rb
module ACRO
class ContestReader
include FlightIdentifier
include Log::ConfigLogger

attr_reader :contest_record

def initialize(control_file)
  @contest_info = ControlFile.new(control_file)
  @participant_list = ParticipantList.new
  @participant_list.read(@contest_info.data_directory)
  @contest_record = Contest.where(:name => @contest_info.name, 
    :start => @contest_info.start_date).first
  if !@contest_record then
    @contest_record = Contest.create(
      :name => @contest_info.name,
      :city => @contest_info.city,
      :state => @contest_info.state,
      :start => @contest_info.start_date,
      :chapter => @contest_info.chapter,
      :director => @contest_info.director,
      :region => @contest_info.region)
  end
  @flights = {}
  @judge_teams = {}
end

def read_contest
  logger.info "Contest reader processing contest, #{@contest_record.year_name}"
  pcs = []
  @contest_info.pilot_flight_result_files.each do |f|
    begin
      logger.info "Contest reader processing file, #{f}"
      pilot_flight_data = YAML.load_file(f)
      process_pilotFlight(pilot_flight_data)
    rescue Exception => e
      logger.warn "ContestReader unable to read contest file, #{f}"
      logger.error "ContestReader#read_contest exception, #{e.message}"
      logger.debug e.backtrace.join("\n")
      pcs << f
    end
  end
  pcs
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
  pilot_flight = flight.pilot_flights.build(:pilot_id => pilot_member.id)
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
  make_model = Airplane.split_make_model(pilot_flight_data.aircraft)
  pilot_flight.airplane = Airplane.find_or_create_by_make_model_reg(
    make_model[0], make_model[1], pilot_flight_data.registration)
  pilot_flight.save
end

###
private
###

def create_or_replace_pilot_flight(pilot_flight_data)
  category = detect_flight_category(pilot_flight_data.flightName)
  name = detect_flight_name(pilot_flight_data.flightName)
  aircat = detect_flight_aircat(pilot_flight_data.flightName)
  logger.info "Flight program: #{aircat} #{category}, #{name}"
  # create flight record first time id seen, infer category and flight
  if (category && name && aircat)
    cat = Category.find_for_cat_aircat(category, aircat)
    logger.info "Category is #{cat.inspect}"
    Flight.where(
      :contest_id => @contest_record, 
      :name => name, 
      :category_id => cat.id).destroy_all
    flight = @contest_record.flights.build(
     :name => name,
     :category_id => cat.id,
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
  judge_team = Judge.new(:judge_id => judge.id)
  @judge_teams[judge] = judge_team
  judge_team.save
  judge_team
end

def find_member(name)
  participant = @participant_list.participant(name)
  if participant && participant.db_id
    Member.find(participant.db_id)
  else
    if participant
      given = participant.given_name
      family = participant.family_name
      iac_id = participant.iac_id
    else
      parts = name.split(' ')
      given = parts[0]
      parts.shift
      family = parts.join(' ')
      iac_id = 0
    end
    Member.find_or_create_by_name(iac_id, given, family)
  end
end

end #class
end #module
