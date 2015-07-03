# Merge multiple member records into one
class MemberMerge
  include Memoist2

  ROLES = [:competitor, :chief_judge, :assist_chief_judge, :line_judge, :assist_line_judge]
  ROLE_NAMES = {
    :competitor => 'Competitor',
    :chief_judge => 'Chief Judge',
    :assist_chief_judge => 'Chief Judge Assistant',
    :line_judge => 'Line Judge',
    :assist_line_judge => 'Line Judge Assistant'
  }

  def self.roles
    ROLES
  end

  def roles
    MemberMerge.roles
  end

  def self.role_name(role)
    ROLE_NAMES[role] || "#{role.to_s} not recognized"
  end

  def role_name(role)
    MemberMerge.role_name(role)
  end

  attr_reader :members

  # create with an array of member id's
  def initialize(member_ids)
    @members = Member.find(member_ids)
    @all_flights = Set.new
    @collisions = Set.new
    @flight_roles = {}
    @role_flights = {}
  end

  def has_multiple_members
    1 < @members.count
  end

  def default_target
    @members.first
  end

  def chief_flights
    @members.inject([]) do |flights, member|
      flights.concat(check_dups_join(:chief_judge, flights, member.chief))
    end
  end
  memoize :chief_flights

  def assist_chief_flights 
    @members.inject([]) do |flights, member|
      flights.concat(check_dups_join(:assist_chief_judge, flights, member.assistChief))
    end
  end
  memoize :assist_chief_flights

  def judge_flights
    @members.inject([]) do |flights, member|
      flights.concat(check_dups_join(:line_judge, flights, member.judge_flights))
    end
  end
  memoize :judge_flights

  def assist_flights
    @members.inject([]) do |flights, member|
      flights.concat(check_dups_join(:assist_line_judge, flights, member.assist_flights))
    end
  end
  memoize :assist_flights

  def competitor_flights
    @members.inject([]) do |flights, member|
      flights.concat(check_dups_join(:competitor, flights, member.flights))
    end
  end
  memoize :competitor_flights

  # array of hash { :role => <role>, :flight => <flight>, :contest => <contest> }
  def flight_collisions
    populate
    @collisions.to_a
  end
  memoize :flight_collisions

  # two or more included members have the same role on the same flight
  def has_collisions
    !flight_collisions.empty?
  end

  # array of hash { flight: <flight>, contest: <contest>, roles: Set of <role> }
  def flight_overlaps
    populate
    overlaps = @flight_roles.select do |key, value|
      1 < value.length
    end
    flat_overlaps = []
    overlaps.each_pair do |contest_flight, roles|
      flat_overlaps << { flight: contest_flight[:flight], contest: contest_flight[:contest], roles: roles }
    end
    flat_overlaps
  end
  memoize :flight_overlaps

  # two or more included members have some role on a given flight
  def has_overlaps
    !flight_overlaps.empty?
  end

  # returns all flights for all members organized by role
  # as an array of hashes: [ { :role => <role>, :contest_flights => [ 
  #  { :flight => <flight_1>, :contest => <contest_1> }, 
  #  { :flight => <flight_2>, :contest => <contest_2> }, 
  # ] }, ... ]
  # see ROLES for the list of roles
  def role_flights
    populate
    participation = []
    ROLES.each do |role|
      flights = @role_flights[role]
      if flights != nil && 0 < flights.length
        participation << { role: role, contest_flights: flights }
      end
    end
    participation
  end
  memoize :role_flights

  def all_flights
    populate
    @all_flights
  end
  memoize :all_flights

  def execute_merge(target_member = nil)
    @target = target_member || @members.first
    unless (@members.include?(@target))
      raise ArgumentError.new("target must be one of the members in the merge") 
    end
    contests = all_flights.collect { |role_flight| role_flight[:contest] }
    merge_members
    contests.uniq.each do |contest|
      Delayed::Job.enqueue Jobs::ComputeFlightsJob.new(contest)
    end
  end

  #######
  private
  #######

  def populate
    chief_flights
    assist_chief_flights
    judge_flights
    assist_flights
    competitor_flights
    true
  end
  memoize :populate

  def check_dups_join(role, flights_accum, flights)
    flights.each do |flight|
      contest = flight.contest
      role_flight = { :role => role, :flight => flight, :contest => contest }
      if (@all_flights.include?(role_flight))
        @collisions.add(role_flight)
      else
        @all_flights.add(role_flight)
      end
      contest_flight = { flight: flight, contest: contest }
      @flight_roles[contest_flight] ||= Set.new
      @flight_roles[contest_flight] << role
      @role_flights[role] ||= []
      @role_flights[role] << contest_flight
    end
    flights
  end

  def merge_members
    target_id = @target.id
    dup_members = @members.reject { |member| member.id == target_id }
    merge_ids = dup_members.collect { |member| member.id }
    pilot_flights = PilotFlight.where(['pilot_id in (?)', merge_ids])
    pilot_flights.update_all(['pilot_id = ?', target_id])
    Flight.where(['chief_id in (?)', merge_ids]).
      update_all(['chief_id = ?', target_id])
    Flight.where(['assist_id in (?)', merge_ids]).
      update_all(['assist_id = ?', target_id])
    RegionalPilot.where(['pilot_id in (?)', merge_ids]).
      update_all(['pilot_id = ?', target_id])
    merge_result_records(target_id, merge_ids)
    replace_judge_pairs(target_id, merge_ids)
    all_ids = Array.new(merge_ids) << target_id
    PcResult.where(['pilot_id in (?)', all_ids]).destroy_all
    JcResult.where(['judge_id in (?)', all_ids]).destroy_all
    JyResult.where(['judge_id in (?)', all_ids]).destroy_all
    Member.where(['id in (?)', merge_ids]).destroy_all
  end

  def merge_result_records(target_id, merge_ids)
    Result.where(['pilot_id in (?)', merge_ids]).
      update_all(['pilot_id = ?', target_id])
    ResultMember.where(['member_id in (?)', merge_ids]).each do |rel|
      if !ResultMember.where(member_id: target_id, result_id: rel.result_id).any?
        rel.member_id = target_id
        rel.save
      else # target member already associated with this result
        rel.destroy
      end
    end
  end

  def replace_judge_pairs(target_id, merge_ids)
    judges_j = Judge.where(['judge_id in (?)', merge_ids])
    judges_j.each do |jp|
      jp.merge_judge(target_id)
      jp.destroy
    end
    judges_a = Judge.where(['assist_id in (?)', merge_ids])
    judges_a.each do |jp|
      jp.merge_assist(target_id)
      jp.destroy
    end
  end
end

