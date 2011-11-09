class PfjResult < ActiveRecord::Base
  belongs_to :pilot_flight
  belongs_to :judge

  serialize :computed_values
  serialize :computed_ranks

end
