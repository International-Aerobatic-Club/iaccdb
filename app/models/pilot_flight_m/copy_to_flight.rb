module PilotFlightM
  module CopyToFlight
    def copy_to_flight(flight)
      new_attrs = self.attributes
      new_attrs.delete('id')
      new_attrs.delete('flight_id')
      pf = flight.pilot_flights.find_by(pilot_id: self.pilot_id)
      if (pf)
        pf.update!(new_attrs)
      else
        pf = flight.pilot_flights.create!(new_attrs)
      end
      copy_grades_to(pf)
      pf
    end

    def copy_grades_to(pf)
      new_judges = self.scores.collect(&:judge_id)
      prior_judges = pf.scores.collect(&:judge_id)
      pf.scores.where(judge_id: prior_judges - new_judges).each do |s|
        pf.scores.delete(s)
      end
      self.scores.each do |s|
        s.extend(ScoreM::CopyToPilotFlight)
        s.copy_to_pilot_flight(pf)
      end
    end
  end
end
