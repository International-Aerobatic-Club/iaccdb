module Jasper
class MemberMap
  def initialize
    @records = {}
  end

  def lookup(iac_id, given_name, family_name)
    @records[key_for(iac_id, given_name, family_name)]
  end

  def insert(iac_id, given_name, family_name, record)
    @records[key_for(iac_id, given_name, family_name)] = record
  end

  private

  def key_for(iac_id, given_name, family_name)
    ['(:', iac_id.to_s, given_name, family_name, ':)'].join(':)-(:')
  end
end
end
