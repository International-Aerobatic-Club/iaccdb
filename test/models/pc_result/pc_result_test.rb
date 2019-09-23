require 'test_helper'

class PcResult::PcResultTest < ActiveSupport::TestCase
  test 'finds cached data' do
    category = create(:category)
    pcr = create(:existing_pc_result, category: category)
    pc_result = PcResult.find_by(
      contest_id: pcr.contest_id,
      category_id: category.id,
      pilot_id: pcr.pilot_id
    )
    assert_equal(4992.14, pc_result.category_value)
    assert_equal(1, pc_result.category_rank)
  end

  # This is really a test for FlightComputer
  test 'behaves on empty sequence' do
    category = create(:category)
    flight = create(:flight, category_id: category.id)
    pf = create(:pilot_flight, flight: flight)
    create(:score,
      :pilot_flight => pf,
      :values => [60, 0, 0, 0, 0])
    create(:score,
      :pilot_flight => pf,
      :values => [-1, 0, 0, 0, 0])
    flight = pf.flight
    computer = FlightComputer.new(flight)
    computer.flight_results(false)
    pc_result = PcResult.find_by(
      contest_id: flight.contest_id,
      category_id: category.id,
      pilot_id: pf.pilot_id
    )
    assert_nil(pc_result)
  end
end
