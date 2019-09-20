module ScoreM
  module CopyToPilotFlight
    def copy_to_pilot_flight(pf)
      new_attrs = self.attributes
      new_attrs.delete('id')
      new_attrs.delete('pilot_flight_id')
      scores = pf.scores.find_by(judge_id: self.judge_id)
      if (scores)
        scores.update(new_attrs)
      else
        scores = pf.scores.create(new_attrs)
      end
      scores
    end
  end
end
