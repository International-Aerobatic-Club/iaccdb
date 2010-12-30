class Member < ActiveRecord::Base
  has_many :chief, :foreign_key => "chief_id", :class_name => "flight"
  has_many :assistChief, :foreign_key => "assist_id", :class_name => "flight"

  def display
    "#{given_name} #{family_name}, iac #{iac_id}"
  end

end
