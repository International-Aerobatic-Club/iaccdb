# Result computations for one pilot + judge_team + flight combination
#   includes results from the judge for each figure of the flight
#
# computed_values holds the actual k scaled value awarded the pilot 
#   for each figure after all computations, including zero adjustments.
#   Values are stored as integer number of tenths (scaled * 10).
#
# graded_values holds the k scaled value for each figure, with average grades
#   replaced by a grade computed from grades of the other judges
#   Values are stored as integer number of tenths (scaled * 10).
#
# computed_ranks holds the effective rank given the pilot by the judge,
#   for each figure, based on computed_values
#
# graded_ranks holds the rank given the pilot by the judge
#   for each figure, based on graded_values
#
# flight_value is the total of all computed values
#   Value is stored as integer number of tenths (scaled * 10).
#
# flight rank is the rank given the pilot by the judge
#   for the flight, based on flight_value
#
class PfjResult < ActiveRecord::Base
  belongs_to :pilot_flight
  belongs_to :judge

  serialize :computed_values
  serialize :computed_ranks
  serialize :graded_values
  serialize :graded_ranks

  def to_s
    "pfj_result for pilot_flight #{pilot_flight.id}, judge #{judge.id}"
  end
end
