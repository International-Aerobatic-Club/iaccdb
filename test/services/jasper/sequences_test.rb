require 'test_helper'
require_relative 'contest_data'

module Jasper
  class SequencesTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperResultsFormat.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'captures known sequences' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = cat.flights.find_by(name: 'Known', contest: @contest)
      refute_nil(flight)
      pilot = Member.where(:family_name => 'Ernewein').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(11, sequence.figure_count)
      assert_equal(130, sequence.total_k)
      assert_equal([17, 7, 4, 14, 15, 16, 14, 17, 10, 10, 6], sequence.k_values)
    end

    test 'captures free sequences' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = cat.flights.find_by(name: 'Free', contest: @contest)
      refute_nil(flight)
      pilot = Member.where(:family_name => 'Wieckowski').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(11, sequence.figure_count)
      assert_equal(133, sequence.total_k)
      assert_equal([7, 14, 19, 18, 10, 14, 13, 16, 11, 5, 6], sequence.k_values)
    end

    test 'captures sportsman second free sequences' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = cat.flights.find_by(name: 'Unknown', contest: @contest)
      refute_nil(flight)
      pilot = Member.where(:family_name => 'Wieckowski').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(11, sequence.figure_count)
      assert_equal(133, sequence.total_k)
      assert_equal([7, 14, 19, 18, 10, 14, 13, 16, 11, 5, 6], sequence.k_values)
    end

    test 'captures unknown sequences' do
      cat = Category.find_for_cat_aircat('Unlimited', 'P')
      flight = cat.flights.find_by(name: 'Unknown', contest: @contest)
      refute_nil(flight)
      pilot = Member.where(:iac_id => '13721').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(14, sequence.figure_count)
      assert_equal(420, sequence.total_k)
      assert_equal([36, 31, 36, 33, 41, 42, 31, 26, 24, 20, 38, 25, 17, 20],
        sequence.k_values)
    end

    test 'captures second unknown sequences' do
      cat = Category.find_for_cat_aircat('Intermediate', 'P')
      flight = cat.flights.find_by(name: 'Unknown II', contest: @contest)
      refute_nil(flight)
      pilot = Member.where(:iac_id => '10467').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(16, sequence.figure_count)
      assert_equal(198, sequence.total_k)
      assert_equal([10, 13, 10, 13, 4, 19, 18, 14, 19, 3, 17, 10, 19, 9, 12, 8],
        sequence.k_values)
    end

    test 'captures four minute free sequences' do
      cat = Category.find_for_cat_aircat('Four Minute', 'F')
      flight = cat.flights.find_by(contest: @contest)
      refute_nil(flight)
      pilot = Member.where(iac_id: 13721).first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(10, sequence.figure_count)
      assert_equal(400, sequence.total_k)
      assert_equal([40, 40, 40, 40, 40, 40, 40, 40, 40, 40], sequence.k_values)
      pilot = Member.where(iac_id: 27381).first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      sequence2 = pilot_flight.sequence
      assert_equal(sequence.id, sequence2.id)
    end
  end
end
