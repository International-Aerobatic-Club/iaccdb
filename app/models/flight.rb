class Flight < ActiveRecord::Base
  belongs_to :contest
  belongs_to :chief, :foreign_key => "chief_id", :class_name => 'Member'
  belongs_to :assist, :foreign_key => "assist_id", :class_name => 'Member'
  has_many :pilot_flights
  has_many :pilots, :through => :pilot_flights, :class_name => 'Member'

  def display
    "#{contest.name} category #{category}, flight #{name}, aircat #{aircat}"
  end

  def displayName
    "#{category} #{'Glider' if aircat == 'G'} #{name}"
  end
end
