require 'test_helper'
require_relative 'contest_data'

module Jasper
  class ScoresTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperResultsFormat.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'captures scores' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = cat.flights.find_by(name: 'Free', contest: @contest)
      refute_nil(flight)
      pilot = Member.where(:family_name => 'Ernewein').first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      judge = Member.where(:family_name => 'Langworthy').first
      refute_nil(judge)
      assist = Member.where(:family_name => 'Comat').first
      refute_nil(assist)
      judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
      scores = pilot_flight.scores.where(:judge_id => judge_team).first
      refute_nil(scores)
      assert_equal([90, 95, 95, 90, 95, 90, 85, 95, 75, 90, 85],
        scores.values)
    end

    test 'captures four minute free scores' do
      cat = Category.find_for_cat_aircat('Four Minute', 'F')
      flight = cat.flights.find_by(contest: @contest)
      refute_nil(flight)
      pilot = Member.where(iac_id: 13721).first
      refute_nil(pilot)
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      refute_nil(pilot_flight)
      judge = Member.where(iac_id: 434884)
      refute_nil(judge)
      assist = Member.where(iac_id: 434247)
      refute_nil(assist)
      judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
      scores = pilot_flight.scores.where(:judge_id => judge_team).first
      refute_nil(scores)
      assert_equal([80, 85, 75, 70, 50, 80, 100, 70, 65, 90], scores.values)
    end
  end
end
