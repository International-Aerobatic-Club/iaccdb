require 'test_helper'

class HorsConcoursTest < ActiveSupport::TestCase

  setup do
    @contest = create :contest
    @contest_computer = ContestComputer.new(@contest)
  end

  def setup_flights(pilot, cat)
    flights = create_list(:flight, 3, contest: @contest, category: cat)
    flights.each do |flight|
      create(:pilot_flight, flight: flight, pilot: pilot)
      create_list(:pilot_flight, 3, flight: flight)
    end
    flights
  end

  def setup_4m_flight(pilot)
    four_cat = create(:category, category: 'four minute', aircat: 'F')
    flight = create(:flight, contest: @contest, category: four_cat)
    create(:pilot_flight, flight: flight, pilot: pilot)
    create_list(:pilot_flight, 3, flight: flight)
    flight
  end

  def setup_pilot_in_pri_and_imd
    @pri_hc_pilot = create :member
    pri_cat = create(:category, category: 'primary', aircat: 'P')
    @pri_flights = setup_flights(@pri_hc_pilot, pri_cat)
    imd_cat = create(:category, category: 'intermediate', aircat: 'P')
    @imd_flights = setup_flights(@pri_hc_pilot, imd_cat)
  end

  def setup_pilot_in_imd_and_unl
    @imd_hc_pilot = create :member
    imd_cat = create(:category, category: 'intermediate', aircat: 'P')
    @imd_flights = setup_flights(@imd_hc_pilot, imd_cat)
    unl_cat = create(:category, category: 'unlimited', aircat: 'P')
    @unl_flights = setup_flights(@imd_hc_pilot, unl_cat)
  end

  test 'identifies solo performance in category' do
    pilot = create :member
    spn_cat = create(:category, category: 'sportsman', aircat: 'P')
    spn_flights = create_list(:flight, 3,
      contest: @contest, category: spn_cat)
    spn_flights.each do |flight|
      create(:pilot_flight, flight: flight, pilot: pilot)
    end
    @contest_computer.compute_flights

    flights = @contest.flights.where(category_id: spn_cat.id)
    assert_equal(3, flights.count)
    pfs = PilotFlight.where(flight_id: flights.collect(&:id))
    assert_equal(3, pfs.count)
    pilots = pfs.all.collect(&:pilot).uniq
    assert_equal(1, pilots.count)
    assert_equal(pilot.family_name, pilots.first.family_name)
    pfs.each do |pf|
      assert(pf.hors_concours?)
    end
  end

  test 'identifies hc of primary also in intermediate' do
    setup_pilot_in_pri_and_imd
    @contest_computer.compute_flights

    pfs = PilotFlight.where(flight_id: @pri_flights.collect(&:id),
      pilot_id: @pri_hc_pilot)
    assert_equal(3, pfs.count)
    pfs.each do |pf|
      assert(pf.hors_concours?)
    end
  end

  test 'identifies non-hc of intermediate also in primary' do
    setup_pilot_in_pri_and_imd
    @contest_computer.compute_flights

    pfs = PilotFlight.where(flight_id: @imd_flights.collect(&:id),
      pilot_id: @pri_hc_pilot)
    assert_equal(3, pfs.count)
    pfs.each do |pf|
      refute(pf.hors_concours?)
    end
  end

  test 'identifies hc of intermediate also in unlimited' do
    setup_pilot_in_imd_and_unl
    @contest_computer.compute_flights

    pfs = PilotFlight.where(flight_id: @imd_flights.collect(&:id), 
      pilot_id: @imd_hc_pilot)
    assert_equal(3, pfs.count)
    pfs.each do |pf|
      assert(pf.hors_concours?)
    end
  end

  test 'identifies non-hc of unlimited also in intermediate' do
    setup_pilot_in_imd_and_unl
    @contest_computer.compute_flights

    pfs = PilotFlight.where(flight_id: @unl_flights.collect(&:id), 
      pilot_id: @imd_hc_pilot)
    assert_equal(3, pfs.count)
    pfs.each do |pf|
      refute(pf.hors_concours?)
    end
  end

  test 'does not mix adv power and 4min aircat' do
    adv_4m_pilot = create :member
    adv_cat = create(:category, category: 'advanced', aircat: 'P')
    setup_flights(adv_4m_pilot, adv_cat)
    setup_4m_flight(adv_4m_pilot)
    @contest_computer.compute_flights

    pfs = PilotFlight.where(flight_id: @contest.flights.collect(&:id),
      pilot_id: adv_4m_pilot.id)
    assert_equal(4, pfs.count)
    pfs.each do |pf|
      refute(pf.hors_concours?)
    end
  end

  test 'does not mix unl power and 4min aircat' do
    unl_4m_pilot = create :member
    unl_cat = create(:category, category: 'unlimited', aircat: 'P')
    setup_flights(unl_4m_pilot, unl_cat)
    setup_4m_flight(unl_4m_pilot)

    pfs = PilotFlight.where(flight_id: @contest.flights.collect(&:id),
      pilot_id: unl_4m_pilot.id)
    assert_equal(4, pfs.count)
    pfs.each do |pf|
      refute(pf.hors_concours?)
    end
  end
end
