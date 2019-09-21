require 'test_helper'

class Flight::CopyToCategoryTest < ActiveSupport::TestCase
  setup do
    @existing = create(:flight)
    @existing.extend(FlightM::CopyToCategory)
    @category = Category.create(category: 'advanced team', aircat: 'P',
      name: 'U.S. Advanced Aerobatic Team', sequence: 12)
  end

  test 'copies existing to new on different category' do
    copied = @existing.copy_to_category(@category)
    refute_equal(@existing.id, copied.id)
    assert_equal(@category.id, copied.category_id)
    assert_equal(@existing.contest_id, copied.contest_id)
    assert_equal(@existing.name, copied.name)
    assert_equal(@existing.sequence, copied.sequence)
    assert_equal(@existing.chief_id, copied.chief_id)
    assert_equal(@existing.assist_id, copied.assist_id)
  end

  test 'does not create duplicate on category' do
    copied = @existing.copy_to_category(@category)
    copied_too = @existing.copy_to_category(@category)
    assert_equal(copied, copied_too)
  end

  test 'copies the pilot_flights' do
    create_list(:pilot_flight, 7, flight: @existing)
    copied = @existing.copy_to_category(@category)
    refute_equal(@existing.id, copied.id)
    assert_equal(@existing.pilot_flights.count, copied.pilot_flights.count)
    e_pilots = @existing.pilot_flights.collect(&:pilot_id).sort
    c_pilots = copied.pilot_flights.collect(&:pilot_id).sort
    assert_equal(e_pilots, c_pilots)
    e_airplanes = @existing.pilot_flights.collect(&:airplane_id).sort
    c_airplanes = copied.pilot_flights.collect(&:airplane_id).sort
    assert_equal(e_airplanes, c_airplanes)
  end

  test 'updates the pilot_flights' do
    create_list(:pilot_flight, 7, flight: @existing)
    @existing.copy_to_category(@category)
    removed = @existing.pilot_flights.first.destroy
    changed = @existing.reload.pilot_flights.first
    changed.update!(penalty_total: changed.penalty_total + 20)
    inserted = create(:pilot_flight, flight: @existing)

    copied = @existing.copy_to_category(@category)

    pilot_ids = copied.pilot_flights.collect(&:pilot_id)
    refute_includes(pilot_ids, removed.pilot_id)
    assert_includes(pilot_ids, inserted.pilot_id)
    changed_copy = copied.pilot_flights.find_by(pilot_id: changed.pilot_id)
    assert_equal(changed.penalty_total, changed_copy.penalty_total)
  end
end
