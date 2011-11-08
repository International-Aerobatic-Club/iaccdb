class PfjResult < ActiveRecord::Base
  belongs_to :pilot_flight
  belongs_to :judge

  serialize :computed_values
  serialize :computed_ranks

  # the computed data for pilot x flight x judge,
  # cached in the database or computed and cached
  # pilot_flight is pilot and particular performance
  # judge is combination of members who judged the flight
  # return instance of PfjResult
  def self.get_pfj(pilot_flight, judge)
    scores = Score.where(:pilot_flight_id => pilot_flight, 
      :judge_id => judge).first
    pfj = PfjResult.where(:pilot_flight_id => pilot_flight, 
      :judge_id => judge).first
    compute = true
    if !pfj
      pfj = PfjResult.new(:pilot_flight => pilot_flight, :judge => judge)
    else
      compute = !scores || pfj.updated_at < scores.updated_at
    end
    if compute
      pfj.flight_value = 0
      pfj.computed_values = []
      if scores && pilot_flight.sequence
        kays = pilot_flight.sequence.k_values
        scores.values.each_with_index do |s,i|
          v = s * kays[i]
          pfj.flight_value += v
          pfj.computed_values[i] = v
        end
      end
      pfj.save
    end
    pfj
  end
end
