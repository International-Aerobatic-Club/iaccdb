require 'test_helper'

class Score::CopyToPilotFlightTest < ActiveSupport::TestCase
  setup do
    @existing = create(:score)
    @existing.extend(ScoreM::CopyToPilotFlight)
    flight = create(:flight, contest: @existing.contest, category:
      @existing.flight.category)
    @pf = create(:pilot_flight, flight: flight)
  end

  test 'copies existing to new on different pilot_flight' do
    copied = @existing.copy_to_pilot_flight(@pf)
    refute_equal(@existing.id, copied.id)
    assert_equal(@pf.id, copied.pilot_flight_id)
    assert_equal(@existing.judge_id, copied.judge_id)
    assert_equal(@existing.values, copied.values)
  end

  test 'does not create duplicate on pilot_flight' do
    copied = @existing.copy_to_pilot_flight(@pf)
    copied_too = @existing.copy_to_pilot_flight(@pf)
    assert_equal(copied, copied_too)
  end
end
