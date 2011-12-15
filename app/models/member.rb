class Member < ActiveRecord::Base
  has_many :chief, :foreign_key => "chief_id", :class_name => "flight"
  has_many :assistChief, :foreign_key => "assist_id", :class_name => "flight"
  has_many :pilot_flights, :foreign_key => "pilot_id"
  has_many :flights, :through => :pilot_flights

  def name
    "#{given_name} #{family_name}"
  end

  def to_s
    "Member #{id} #{name}, IAC #{iac_id}"
  end

  # find or create member with bad or mismatched IAC ID
  # member family and given names must match exatly, otherwise
  # this creates a new member record
  def self.find_or_create_by_name(iac_id, given_name, family_name)
    dm = Member.where(:family_name => family_name,
      :given_name =>given_name).first
    if dm
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
  # IAC ID and family name must match exactly, otherwise this falls
  # back to exact match of family name and given name
  def self.find_or_create_by_iac_number(iac_id, given_name, family_name)
    dm = Member.where(:iac_id => iac_id).first
    if dm 
      Member.logger.info "Found member #{dm.to_s}"
      if dm.family_name.downcase != family_name.downcase
        # different, fallback to name match
        Member.logger.warn "Member family name mismatch." +
          " caller has #{family_name}"
        dm = Member.find_or_create_by_name(iac_id, given_name, family_name)
      end
    else
      dm = Member.find_or_create_by_name(iac_id, given_name, family_name)
    end
    dm
  end

end
