# Result computations for one pilot + judge_team + flight combination
#   includes results from the judge for each figure of the flight
#
# computed_values holds the actual k scaled value awarded the pilot 
#   for each figure after all computations, including zero adjustments
#
# graded_values holds the k scaled value for each figure, with average grades
#   replaced by a grade computed from grades of the other judges
#
# computed_ranks holds the effective rank given the pilot by the judge,
#   for each figure, based on computed_values
#
# graded_ranks holds the rank given the pilot by the judge
#   for each figure, based on graded_values
#
# flight_value is the total of all computed values
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

end
