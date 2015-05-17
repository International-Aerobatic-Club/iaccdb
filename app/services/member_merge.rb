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

  def flight_collisions
    populate
    @collisions.to_a
  end
  memoize :flight_collisions

  def has_collisions
    !flight_collisions.empty?
  end

  def flight_overlaps
    populate
    @flight_roles.select do |key, value|
      1 < value.length
    end
  end
  memoize :flight_overlaps

  def has_overlaps
    !flight_overlaps.empty?
  end

  def role_flights
    populate
    @role_flights
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
    contests = all_flights.collect { |role_flight| role_flight[:flight].contest }
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
      role_flight = { :role => role, :flight => flight }
      if (@all_flights.include?(role_flight))
        @collisions.add(role_flight)
      else
        @all_flights.add(role_flight)
      end
      @flight_roles[flight] ||= []
      @flight_roles[flight] << role
      @role_flights[role] ||= []
      @role_flights[role] << flight
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
    PcResult.where(['pilot_id in (?)', merge_ids]).destroy_all
    JcResult.where(['judge_id in (?)', merge_ids]).destroy_all
    JyResult.where(['judge_id in (?)', merge_ids]).destroy_all
    RegionalPilot.where(['pilot_id in (?)', merge_ids]).destroy_all
    merge_result_records(target_id, merge_ids)
    replace_judge_pairs(target_id, merge_ids)
    Member.where(['id in (?)', merge_ids]).destroy_all
  end

  def merge_result_records(target_id, merge_ids)
    Result.where(['pilot_id in (?)', merge_ids]).
      update_all(['pilot_id = ?', target_id])
    ResultMember.where(['member_id in (?)', merge_ids]).each do |rel|
      if !ResultMember.where(member_id: target_id, result_id: rel.result_id).any?
        rel.member_id = target_id
        rel.save
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

