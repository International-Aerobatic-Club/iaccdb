class Score < ActiveRecord::Base
  belongs_to :pilot_flight
  belongs_to :judge
  has_one :pilot, :through => :pilot_flight
  has_one :contest, :through => :pilot_flight
  has_one :category, :through => :pilot_flight
  has_one :flight, :through => :pilot_flight

  serialize :values

  def to_s
    s = "Scores #{id} #{pilot_flight}, #{judge} (" +
      values.join(', ') + ")"
  end

  # convert the value * 10 into a pretty decimal
  def self.display_score(score)
    score < 0 ? 'A' : sprintf('%0.1f', score.fdiv(10))
  end
end
