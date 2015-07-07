class Member < ActiveRecord::Base
  attr_protected :id

  has_many :chief, :foreign_key => 'chief_id', :class_name => 'Flight'
  has_many :assistChief, :foreign_key => 'assist_id', :class_name => 'Flight'
  has_many :pilot_flights, :foreign_key => 'pilot_id'
  has_many :flights, :through => :pilot_flights
  has_many :judge, :foreign_key => 'judge_id', :class_name => 'Judge'
  has_many :assist, :foreign_key => 'assist_id', :class_name => 'Judge'
  has_many :jc_results, :foreign_key => 'judge_id', :dependent => :destroy
  has_many :jy_results, :foreign_key => 'judge_id', :dependent => :destroy
  has_many :pc_results, :foreign_key => 'pilot_id', :dependent => :destroy
  has_many :result_members
  has_many :teams, :through => :result_members, :source => :result
  has_many :results, :foreign_key => 'pilot_id'

  def self.missing_member
    missing_member = Member.where(iac_id: 0, given_name: 'Missing', family_name: 'Member').first
    if (missing_member == nil)
      missing_member = Member.create(iac_id: 0, given_name: 'Missing', family_name: 'Member')
    end
    missing_member
  end

  def name
    "#{given_name} #{family_name}"
  end

  def to_s
    "Member #{id} #{name}, IAC #{iac_id}"
  end

  # Do not call this if you have an IAC number.
  # Use find_or_create_by_iac_number
  # This will find or create member with bad or mismatched IAC ID
  # Returns record where member family and given names match exactly and uniquely, 
  # otherwise this creates a new member record
  def self.find_or_create_by_name(iac_id, given_name, family_name)
    dm = Member.where(:family_name => family_name,
      :given_name =>given_name).order(:id)
    if 0 < dm.count
      dm = dm.first
      Member.logger.info "Found by name member #{dm.to_s}"
    else
      dm = Member.create(
        :iac_id => iac_id,
        :given_name => given_name,
        :family_name => family_name)
      Member.logger.info "New member #{dm.to_s}"
    end
    dm
  end

  # find or create member with good IAC ID
  # IAC ID and family name must match exactly, otherwise this fails
  # back to exact match of family name and given name
  def self.find_or_create_by_iac_number(iac_id, given_name, family_name)
    mmr = nil
    dm = Member.where(:iac_id => iac_id).order(:id)
    if 0 < dm.count
      mmra = dm.to_a.select { |m| m.family_name.downcase == family_name.downcase }
      mmr = mmra[0] if (0 < mmra.size)
    end
    mmr ||= Member.find_or_create_by_name(iac_id, given_name, family_name)
  end

  def judge_flights
    judge_flights = Set.new
    judge.each do |judge|
      judge.pilot_flights.each do |pilot_flight|
        judge_flights << pilot_flight.flight
      end
    end
    (judge_flights - [nil]).to_a
  end

  def assist_flights
    assist_flights = Set.new
    assist.each do |assist|
      assist.pilot_flights.each do |pilot_flight|
        assist_flights << pilot_flight.flight
      end
    end
    (assist_flights - [nil]).to_a
  end

  # returns array of pc_result is contest results for given year
  # returns empty if no contest results
  def contests(year)
    pc_results.joins(:c_result => :contest).where('year(contests.start) = ?', year).all
  end

end
