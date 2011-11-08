class PfResult < ActiveRecord::Base
  belongs_to :pilot_flight

  def self.get_pf(pilot_flight)
    compute = false
    pf = PfResult.where(:pilot_flight_id => pilot_flight).first
    if !pf
      pf = PfResult.new(:pilot_flight => pilot_flight)
      compute = true
    end
    pfj = {}
    scores = Score.where(:pilot_flight_id => pilot_flight)
    scores.each do |score|
      pfj[score.judge] = PfjResult.get_pfj(pilot_flight, score.judge)
      if pfj[score.judge].new_record?
        compute = true
      else
        compute ||= pf.updated_at < pfj[score.judge].updated_at
      end
    end
    if compute
      pf.flight_value = 0
      pfj.each_value do |js|
        pf.flight_value += js.flight_value
      end
      pf.flight_value /= (pfj.length * 10.0) # scores are stored * 10
      pf.adj_flight_value = pf.flight_value - pilot_flight.penalty_total
      pf.save
    end
    pf
  end

end
