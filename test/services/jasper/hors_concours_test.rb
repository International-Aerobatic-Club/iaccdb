require 'test_helper'
require_relative 'contest_data'

module Jasper
  class HorsConcoursTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperResultsTestHC.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
      @pri_cat = Category.find_for_cat_aircat('primary', 'P')
      @int_cat = Category.find_for_cat_aircat('intermediate', 'P')
      @unl_cat = Category.find_for_cat_aircat('unlimited', 'P')
      @pri_hc_pilot = Member.where(iac_id: 432890).first
      @int_hc_pilot = Member.where(iac_id: 431051).first
      @pri_flights = @contest.flights.where(category_id: @pri_cat.id)
      @int_flights = @contest.flights.where(category_id: @int_cat.id)
      @unl_flights = @contest.flights.where(category_id: @unl_cat.id)
    end

    test 'identifies solo performance in category' do
      spn = Category.find_for_cat_aircat('sportsman', 'P')
      flights = @contest.flights.where(category_id: spn.id)
      assert_equal(3, flights.count)
      pfs = PilotFlight.where(flight_id: flights.collect(&:id))
      assert_equal(3, pfs.count)
      pilots = pfs.all.collect(&:pilot).uniq
      assert_equal(1, pilots.count)
      assert_equal('Eggen', pilots.first.family_name)
      pfs.each do |pf|
        assert(pf.hors_concours?)
      end
    end

    test 'finds the right pilot' do
      assert_equal('Lisser', @pri_hc_pilot.family_name)
      assert_equal('Endo', @int_hc_pilot.family_name)
    end

    test 'finds the right number of flights' do
      assert_equal(3, @int_flights.count)
      assert_equal(3, @pri_flights.count)
    end

    test 'identifies hc of primary also in intermediate' do
      pfs = PilotFlight.where(flight_id: @pri_flights.collect(&:id), 
        pilot_id: @pri_hc_pilot)
      assert_equal(3, pfs.count)
      pfs.each do |pf|
        assert(pf.hors_concours?)
      end
    end

    test 'identifies non-hc of intermediate also in primary' do
      pfs = PilotFlight.where(flight_id: @int_flights.collect(&:id), 
        pilot_id: @pri_hc_pilot)
      assert_equal(3, pfs.count)
      pfs.each do |pf|
        refute(pf.hors_concours?)
      end
    end

    test 'identifies hc of intermediate also in unlimited' do
      pfs = PilotFlight.where(flight_id: @int_flights.collect(&:id), 
        pilot_id: @int_hc_pilot)
      assert_equal(3, pfs.count)
      pfs.each do |pf|
        assert(pf.hors_concours?)
      end
    end

    test 'identifies non-hc of unlimited also in intermediate' do
      pfs = PilotFlight.where(flight_id: @unl_flights.collect(&:id), 
        pilot_id: @int_hc_pilot)
      assert_equal(3, pfs.count)
      pfs.each do |pf|
        refute(pf.hors_concours?)
      end
    end

    test 'does not mix adv power and 4min aircat' do
      adv_4m_pilot = Member.where(iac_id: 433052).first
      pfs = PilotFlight.where(flight_id: @contest.flights.collect(&:id),
        pilot_id: adv_4m_pilot.id)
      assert_equal(4, pfs.count)
      pfs.each do |pf|
        refute(pf.hors_concours?)
      end
    end

    test 'does not mix unl power and 4min aircat' do
      unl_4m_pilot = Member.where(iac_id: 8532).first
      pfs = PilotFlight.where(flight_id: @contest.flights.collect(&:id),
        pilot_id: unl_4m_pilot.id)
      assert_equal(4, pfs.count)
      pfs.each do |pf|
        refute(pf.hors_concours?)
      end
    end
  end
end
