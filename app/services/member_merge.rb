# Merge multiple member records into one
class MemberMerge

  # create with an array of member id's
  def initialize(member_ids)
    @members = Member.find(member_ids)
    @collisions = []
    @all_flights = []
  end

  def has_multiple_members
    1 < @members.count
  end

  def chief_flights
    @members.inject([]) do |flights, member|
      check_dups_join(flights, member.chief) 
    end
  end

  def assist_chief_flights 
    @members.inject([]) do |flights, member|
      check_dups_join(flights, member.assistChief) 
    end
  end

  def judge_flights
    @members.inject([]) do |flights, member|
      check_dups_join(flights, member.judge_flights) 
    end
  end

  def assist_flights
    @members.inject([]) do |flights, member|
      check_dups_join(flights, member.assist_flights) 
    end
  end

  def competitor_flights
    @members.inject([]) do |flights, member|
      check_dups_join(flights, member.flights) 
    end
  end

  def target 
    @target || @members.first.id
  end

  def has_collisions
    !@collisions.empty?
  end

  def collisions
    @collisions.uniq
  end

  ###
  private
  ###

  def check_dups_join(flights_accum, flights)
    overlap = @all_flights & flights
    if !overlap.empty?
      @collisions ||= []
      @collisions.concat(overlap)
    end
    @all_flights.concat(flights)
    flights_accum + flights
  end
end

