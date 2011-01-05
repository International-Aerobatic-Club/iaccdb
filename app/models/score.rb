class Score < ActiveRecord::Base
  belongs_to :pilot_flight
  belongs_to :judge

  serialize :values
end
