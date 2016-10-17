module MemberMerge
class RoleFlight
  attr_reader :role, :flight, :contest

  def initialize(role, flight)
    unless roles.include?(role)
      raise ArgumentError.new "Role #{role} must be one of #{roles.inspect}"
    end
    unless flight
      raise ArgumentError.new 'Flight must not be nil'
    end
    unless flight.id
      raise ArgumentError.new 'Flight must have a database record id'
    end
    @role = role
    @flight = flight
    @contest = flight.contest
  end

  def hash
    flight.id << 3 + ROLES.index(role)
  end

  def eql?(o)
    o.instance_of?(self.class) && (o == self || o.hash == hash)
  end

  def self.roles
    ROLES
  end

  def roles
    self.class.roles
  end

  def self.role_name(role)
    ROLE_NAMES[role] || "#{role.to_s} not recognized"
  end

  def role_name
    self.class.role_name(role)
  end

  #######
  private
  #######

  ROLES = [:competitor, :chief_judge, :assist_chief_judge, :line_judge, :assist_line_judge]
  ROLE_NAMES = {
    :competitor => 'Competitor',
    :chief_judge => 'Chief Judge',
    :assist_chief_judge => 'Chief Judge Assistant',
    :line_judge => 'Line Judge',
    :assist_line_judge => 'Line Judge Assistant'
  }

end
end
