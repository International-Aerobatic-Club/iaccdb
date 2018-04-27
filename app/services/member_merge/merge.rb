# Merge multiple member records into one
module MemberMerge
class Merge
  attr_reader :members

  # create with an array of member id's
  def initialize(member_ids)
    @merge_summary = MergeFlights.new
    @members = Member.find(member_ids)
    populate
  end

  def has_multiple_members
    1 < members.count
  end

  def default_target
    members.first
  end

  def chief_flights
    @merge_summary.role_flights[:chief_judge]
  end

  def assist_chief_flights
    @merge_summary.role_flights[:assist_chief_judge]
  end

  def judge_flights
    @merge_summary.role_flights[:line_judge]
  end

  def assist_flights
    @merge_summary.role_flights[:assist_line_judge]
  end

  def competitor_flights
    @merge_summary.role_flights[:competitor]
  end

  # array of hash {
  #  flight: <flight description>,
  #  contest: <contest description>,
  #  roles: <roles description> }
  def flight_collisions
    flight_role_flights = {}
    @merge_summary.collisions.each do |collision|
      flight = collision.flight
      flight_role_flights[flight] ||= []
      flight_role_flights[flight] << collision
    end
    flight_role_flights.keys.collect do |flight|
      role_flights = flight_role_flights[flight]
      roles = role_flights.collect do |role_flight|
        role_flight.role_name
      end
      {
        flight: flight.displayName,
        contest: flight.contest.year_name,
        roles: roles.join(', ')
      }
    end
  end

  # two or more included members have the same role on the same flight
  def has_collisions
    !flight_collisions.empty?
  end

  # hash keyed on flight, value: Set of <role>
  # list of hash {
  #   flight: Flight description
  #   contest: Contest description
  #   roles: Role descriptions
  # }
  def flight_overlaps
    fos = []
    overlaps = @merge_summary.flight_overlaps
    overlaps.each_key do |flight|
      flight_description = flight.displayName
      contest_description = flight.contest.year_name
      role_names = overlaps[flight].collect do |role_flight|
        role_flight.role_name
      end
      fos << {
        flight: flight_description,
        contest: contest_description,
        roles: role_names.join(', ')
      }
    end
    fos
  end

  # two or more included members have some role on a given flight
  def has_overlaps
    !flight_overlaps.empty?
  end

  # returns all flights for all members organized by role
  # as an array of hashes: [ { :role => role symbol, :contest_flights => [
  #  { :flight => <flight_1>, :contest => <contest_1> }, 
  #  { :flight => <flight_2>, :contest => <contest_2> }, 
  # ] }, ... ]
  def role_flights
    participation = []
    RoleFlight.roles.each do |role|
      flights = @merge_summary.flights_for(role)
      if flights != nil && 0 < flights.length
        participation << { role: role, contest_flights: flights }
      end
    end
    participation
  end

  # all flights mixed-up in the member merge
  def execute_merge(target_member = nil)
    @target = target_member || default_target
    target_id = @target.id
    unless (members.include?(@target))
      raise ArgumentError.new("target #{@target} must be one of the members in the merge") 
    end
    dup_members = members.reject { |member| member == @target }
    merge_members(target_id, dup_members)
    recompute_changed_contests(dup_members)
  end

  #######
  private
  #######

  def populate
    members.each do |member|
      @merge_summary.add_flights_for_role(:chief_judge, member.chief)
      @merge_summary.add_flights_for_role(:assist_chief_judge, member.assistChief)
      @merge_summary.add_flights_for_role(:line_judge, member.judge_flights)
      @merge_summary.add_flights_for_role(:assist_line_judge, member.assist_flights)
      @merge_summary.add_flights_for_role(:competitor, member.flights)
    end
  end

  def recompute_changed_contests(dup_members)
    judge_contests = []
    pilot_contests = []
    dup_members.each do |member|
      judge_contests << member.judge_flights.collect{ |f| f.contest }
      pilot_contests << member.flights.collect{ |f| f.contest }
    end
    judge_contests.flatten.uniq.each do |contest|
      Delayed::Job.enqueue Jobs::ComputeContestJudgeRollupsJob.new(contest)
    end
    pilot_contests.flatten.uniq.each do |contest|
      Delayed::Job.enqueue Jobs::ComputeContestPilotRollupsJob.new(contest)
    end
  end

  def merge_members(target_id, dup_members)
    merge_ids = dup_members.collect { |member| member.id }

    PilotFlight.where(['pilot_id in (?)', merge_ids]).
      update_all(['pilot_id = ?', target_id])
    Flight.where(['chief_id in (?)', merge_ids]).
      update_all(['chief_id = ?', target_id])
    Flight.where(['assist_id in (?)', merge_ids]).
      update_all(['assist_id = ?', target_id])
    RegionalPilot.where(['pilot_id in (?)', merge_ids]).
      update_all(['pilot_id = ?', target_id])

    merge_result_records(target_id, merge_ids)
    replace_judge_pairs(target_id, merge_ids)

    # will recompute for affected contests
    PcResult.where(pilot: dup_members).destroy_all
    JcResult.where(judge: dup_members).destroy_all

    # will recompute for affected years
    JyResult.where(judge: dup_members).destroy_all

    # finally, remove the orphaned members
    Member.where(['id in (?)', merge_ids]).destroy_all
  end

  def merge_result_records(target_id, merge_ids)
    Result.where(['pilot_id in (?)', merge_ids]).
      update_all(['pilot_id = ?', target_id])
    ResultMember.where(['member_id in (?)', merge_ids]).each do |rel|
      if !ResultMember.where(member_id: target_id, result_id: rel.result_id).any?
        rel.member_id = target_id
        rel.save!
      else # target member already associated with this result
        rel.destroy
      end
    end
  end

  def replace_judge_pairs(target_id, merge_ids)
    judges_j = Judge.where(['judge_id in (?)', merge_ids])
    judges_j.each do |jp|
      new_judge_pair = Judge.find_or_create_by(
        judge_id: target_id,
        assist: jp.assist)
      replace_judge(jp, new_judge_pair)
    end
    judges_a = Judge.where(['assist_id in (?)', merge_ids])
    judges_a.each do |jp|
      new_judge_pair = Judge.find_or_create_by(
        judge: jp.judge,
        assist_id: target_id)
      replace_judge(jp, new_judge_pair)
    end
  end

  # replace all judge_pair instances of outgoing
  # with new judge pair replacement,
  # then destroy the outgoing
  # do nothing if outgoing and replacement are the same pair (same id)
  def replace_judge(outgoing, replacement)
    if (outgoing.id != replacement.id)
      Score.where('judge_id = ?', outgoing.id).update_all(judge_id: replacement.id)
      PfjResult.where('judge_id = ?', outgoing.id).update_all(judge_id: replacement.id)
      JfResult.where('judge_id = ?', outgoing.id).update_all(judge_id: replacement.id)
      outgoing.destroy
    end
  end

end
end

