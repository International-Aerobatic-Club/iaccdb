require 'test_helper'
require_relative 'contest_data'

module Jasper
  class UnknownKTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperFreeUnknown.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'captures free sequence' do
      cat = Category.find_for_cat_aircat('Advanced', 'P')
      flight = cat.flights.find_by(sequence: 2, contest: @contest)
      refute_nil(flight)
      pilot = Member.where(family_name: 'Lovell').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(pilot_id: pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(16, sequence.figure_count)
      assert_equal(325, sequence.total_k)
      assert_equal(
        [23, 14, 21, 12, 18, 16, 23, 15, 11, 25, 24, 21, 27, 29, 21, 25],
        sequence.k_values)
    end

    test 'captures free unknown sequence' do
      cat = Category.find_for_cat_aircat('Advanced', 'P')
      flight = cat.flights.find_by(sequence: 3, contest: @contest)
      refute_nil(flight)
      pilot = Member.where(family_name: 'Lovell').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(pilot_id: pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(16, sequence.figure_count)
      assert_equal(400, sequence.total_k)
      assert_equal(
        [15, 18, 32, 23, 24, 34, 18, 36, 28, 26, 24, 33, 15, 28, 21, 25],
        sequence.k_values)
    end

    test 'captures second free unknown sequence' do
      cat = Category.find_for_cat_aircat('Advanced', 'P')
      flight = cat.flights.find_by(sequence: 4, contest: @contest)
      refute_nil(flight)
      pilot = Member.where(family_name: 'Lovell').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(pilot_id: pilot).first
      refute_nil(pilot_flight)
      sequence = pilot_flight.sequence
      refute_nil(sequence)
      assert_equal(16, sequence.figure_count)
      assert_equal(412, sequence.total_k)
      assert_equal(
        [14, 32, 12, 28, 27, 25, 26, 34, 31, 29, 18, 22, 25, 31, 33, 25],
        sequence.k_values)
    end
  end
end
