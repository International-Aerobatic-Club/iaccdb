class JfResult::JudgeGrades
  attr_reader :jf_result

  def initialize(jf_result)
    @jf_result = jf_result
  end

  # the member judge, not the judge_pair
  def judge
    @jf_result.judge.judge
  end

  def assistant
    @jf_result.judge.assist
  end

  # all of the judge's grades for the flight
  # an array of scores
  def grades
    pilot_flights = PilotFlight.where(flight: @jf_result.flight)
    Score.where(
      judge: @jf_result.judge,
      pilot_flight: pilot_flights).to_a
  end
end
