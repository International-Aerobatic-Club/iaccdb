class Flight < ActiveRecord::Base
  belongs_to :contest
  belongs_to :chief, :foreign_key => "chief_id", :class_name => 'Member'
  belongs_to :assist, :foreign_key => "assist_id", :class_name => 'Member'
  has_many :pilot_flights
  has_many :pilots, :through => :pilot_flights, :class_name => 'Member'

  def to_s
    "#{contest.name} category #{category}, flight #{name}, aircat #{aircat}"
  end

  def displayName
    "#{displayCategory} #{name if category != 'Four Minute Free'}"
  end

  def displayCategory
    "#{category} #{'Glider' if aircat == 'G'}"
  end

  def count_judges
    Judge.find_by_sql("select distinct s.judge_id 
      from scores s, pilot_flights p 
      where p.flight_id = #{id} and s.pilot_flight_id = p.id").count
  end
end
