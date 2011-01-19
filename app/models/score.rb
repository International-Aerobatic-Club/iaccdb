class Score < ActiveRecord::Base
  belongs_to :pilot_flight
  belongs_to :judge

  serialize :values

  # convert the value * 10 into a pretty decimal
  def self.display_score(score)
    score < 0 ? 'A' : sprintf('%0.1f', score.fdiv(10))
  end
end
