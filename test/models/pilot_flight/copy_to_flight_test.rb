require 'test_helper'

class PilotFlight::CopyToFlightTest < ActiveSupport::TestCase
  setup do
    @existing = create(:pilot_flight)
    @existing.extend(PilotFlightM::CopyToFlight)
    @flight = create :flight
  end

  test 'copies existing to new on different flight' do
    copied = @existing.copy_to_flight(@flight)
    refute_equal(@existing.id, copied.id)
    assert_equal(@flight.id, copied.flight_id)
    assert_equal(@existing.pilot_id, copied.pilot_id)
    assert_equal(@existing.sequence_id, copied.sequence_id)
    assert_equal(@existing.airplane_id, copied.airplane_id)
    assert_equal(@existing.chapter, copied.chapter)
    assert_equal(@existing.penalty_total, copied.penalty_total)
    assert_equal(@existing.hors_concours, copied.hors_concours)
  end

  test 'does not create duplicate on flight' do
    copied = @existing.copy_to_flight(@flight)
    copied_too = @existing.copy_to_flight(@flight)
    assert_equal(copied, copied_too)
  end

  test 'copies the scores' do
    create_list(:score, 7, pilot_flight: @existing)
    copied = @existing.copy_to_flight(@flight)
    refute_equal(@existing.id, copied.id)
    assert_equal(@existing.scores.count, copied.scores.count)
    e_judges = @existing.scores.collect(&:judge_id).sort
    c_judges = copied.scores.collect(&:judge_id).sort
    assert_equal(e_judges, c_judges)
    e_grades = @existing.scores.collect(&:values).flatten.sort
    c_grades = copied.scores.collect(&:values).flatten.sort
    assert_equal(e_grades, c_grades)
  end

  test 'updates the scores' do
    create_list(:score, 7, pilot_flight: @existing)
    @existing.copy_to_flight(@flight)
    removed = @existing.scores.first.destroy
    changed = @existing.reload.scores.first
    changed.update!(values: changed.values.map{ |v| v - 5 })
    inserted = create(:score, pilot_flight: @existing)

    copied = @existing.copy_to_flight(@flight)

    judge_ids = copied.scores.collect(&:judge_id)
    refute_includes(judge_ids, removed.judge_id)
    assert_includes(judge_ids, inserted.judge_id)
    changed_copy = copied.scores.find_by(judge_id: changed.judge_id)
    assert_equal(changed.values, changed_copy.values)
  end
end
