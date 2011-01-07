class Member < ActiveRecord::Base
  has_many :chief, :foreign_key => "chief_id", :class_name => "flight"
  has_many :assistChief, :foreign_key => "assist_id", :class_name => "flight"
  has_many :pilot_flights, :foreign_key => "pilot_id"
  has_many :flights, :through => :pilot_flights

  def name
    "#{given_name} #{family_name}"
  end

  def display
    "#{name}, iac #{iac_id}"
  end

end
