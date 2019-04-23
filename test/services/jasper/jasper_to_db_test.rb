require 'test_helper'
require_relative 'contest_data'

module Jasper
  class JasperToDbTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperResultsFormat.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'captures a contest' do
      refute_nil(@contest)
      refute_nil(@contest.id)
      assert_equal("Test Contest US Candian Challenge", @contest.name)
      assert_equal(23, @contest.start.day)
      assert_equal(2014, @contest.start.year)
      assert_equal(12, @contest.start.month)
      assert_equal('NorthEast', @contest.region)
      assert_equal('Pat Barrett', @contest.director)
      assert_equal('Olean', @contest.city)
      assert_equal('NY', @contest.state)
      assert_equal(126, @contest.chapter)
    end

    test 'captures flights' do
      cat = Category.find_for_cat_aircat('Unlimited', 'P')
      flights = @contest.flights.where(:category_id => cat.id, :name => 'Unknown')
      assert_equal(1, flights.count)
      assert_equal(2383, flights.first.chief.iac_id)
      assert_equal(18515, flights.first.assist.iac_id)
    end

    test 'captures pilots' do
      pilot = Member.find_by_iac_id(434969)
      refute_nil(pilot)
      assert_equal('Desmond', pilot.given_name)
      assert_equal('Lightbody', pilot.family_name)
    end

    test 'captures judge teams' do
      judge = Member.where(:iac_id => 431885).first
      refute_nil(judge)
      assert_equal('Sanford', judge.given_name)
      assert_equal('Langworthy', judge.family_name)
      assistant = Member.where(:iac_id => 433272).first
      refute_nil(assistant)
      assert_equal('Hella', assistant.given_name)
      assert_equal('Comat', assistant.family_name)
      judge_team = Judge.where(:judge_id => judge.id, :assist_id => assistant.id).first
      refute_nil(judge_team)
    end

    test 'captures pilot flights' do
      cat = Category.find_for_cat_aircat('Intermediate', 'P')
      flight = @contest.flights.where(:category_id => cat.id, :name => 'Unknown').first
      pilot = Member.find_by_iac_id(10467)
      pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
      refute_nil(pilot_flight)
      assert_equal(100, pilot_flight.penalty_total)
    end

    test 'captures airplanes' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = @contest.flights.where( :name => 'Known', :category_id => cat.id).first
      refute_nil(flight)
      pilot = Member.where(:family_name => 'Ernewein').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      airplane = pilot_flight.airplane
      refute_nil(airplane)
      assert_equal('Bucker Youngman', airplane.make)
      assert_equal('131', airplane.model)
      assert_equal('CFLXE', airplane.reg)
    end

    test 'filters pilot chapter number' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = @contest.flights.where(category_id: cat.id, name: 'Known').first
      pilot = Member.find_by_iac_id(12058)
      pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
      assert_equal('3/52', pilot_flight.chapter)
      pilot = Member.find_by_iac_id(430273)
      pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
      assert_equal('126/12', pilot_flight.chapter)
      pilot = Member.find_by_iac_id(434969)
      pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
      assert_equal('3/126/12', pilot_flight.chapter)
      pilot = Member.find_by_iac_id(434884)
      pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
      assert_equal('35/52', pilot_flight.chapter)
    end
  end
end
