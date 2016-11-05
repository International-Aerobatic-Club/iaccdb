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
  # an AR result list of Score records
  def grades
    pilot_flights = PilotFlight.where(flight: @jf_result.flight)
    all_scores = Scores.where(
      judge: @jf_result.judge,
      pilot_flight: flights)
  end
end
