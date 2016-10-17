module MemberMerge
class MergeFlights
  # Set of RoleFlight that occurred more than once
  # Exact flight and role combination was repeated
  attr_reader :collisions

  def initialize
    @all_flights = Set.new
    @collisions = Set.new
    @roles_by_flight = {} # index is flight, value is Set of RoleFlight
    @flights_by_role = {} # index is role symbol, value is array of Flight
  end

  # add all from Array of Flight to role given by role symbol
  # record any collisions of same role on the same flight
  def add_flights_for_role(role, flights)
    flights.each do |flight|
      role_flight = RoleFlight.new(role, flight)
      if (@all_flights.include?(role_flight))
        @collisions.add(role_flight)
      else
        @all_flights.add(role_flight)
      end
      @roles_by_flight[flight] ||= Set.new
      @roles_by_flight[flight] << role_flight
      @flights_by_role[role] ||= []
      @flights_by_role[role] << flight
    end
    flights
  end

  # Set of RoleFlight for given Flight
  def roles_for(flight)
    @roles_by_flight[flight]
  end

  # Array of Flight for given role symbol
  def flights_for(role)
    @flights_by_role[role]
  end

  # Hash of Flight => Set of RoleFlight
  def flight_overlaps
    @roles_by_flight.select do |flight, roles|
      1 < roles.length
    end
  end
end
end

