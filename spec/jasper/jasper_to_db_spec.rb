require 'spec_helper'
#require 'iac/jasper_parse'
#require 'iac/jasper_to_db'
require 'xml'

module Jasper
  describe JasperToDB do
    before(:all) do 
      testFile = 'spec/jasper/jasperResultsFormat.xml'
      jasper = Jasper::JasperParse.new
      parser = XML::Parser.file(testFile)
      jasper.do_parse(parser)
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end
    it 'captures a contest' do
      @contest.should_not be_nil
      @contest.id.should_not be_nil
      @contest.name.should == "Test Contest US Candian Challenge"
      @contest.start.day.should == 23
      @contest.start.year.should == 2014
      @contest.start.month.should == 12
      @contest.region.should == 'NorthEast'
      @contest.director.should == 'Pat Barrett'
      @contest.city.should == 'Olean'
      @contest.state.should == 'NY'
      @contest.chapter.should == 126
    end
    it 'captures flights' do
      cat = Category.find_for_cat_aircat('Unlimited', 'P')
      flights = @contest.flights.where(:category_id => cat.id, :name => 'Unknown')
      flights.count.should == 1
      flights.first.chief.iac_id.should == 2383
      flights.first.assist.iac_id.should == 18515
    end
    it 'captures pilots' do
      pilot = Member.find_by_iac_id(434969)
      pilot.should_not be_nil
      pilot.given_name.should == 'Desmond'
      pilot.family_name.should == 'Lightbody'
    end
    it 'captures judge teams' do
      judge = Member.where(:iac_id => 431885).first
      judge.should_not be_nil
      judge.given_name.should == 'Sanford'
      judge.family_name.should == 'Langworthy'
      assistant = Member.where(:iac_id => 433272).first
      assistant.should_not be_nil
      assistant.given_name.should == 'Hella'
      assistant.family_name.should == 'Comat'
      judge_team = Judge.where(:judge_id => judge.id, :assist_id => assistant.id).first
      judge_team.should_not be_nil
    end
    it 'captures pilot flights' do
      cat = Category.find_for_cat_aircat('Intermediate', 'P')
      flight = @contest.flights.where(:category_id => cat.id, :name => 'Unknown').first
      pilot = Member.find_by_iac_id(10467)
      pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
      pilot_flight.should_not be_nil
      pilot_flight.penalty_total.should == 100
    end
    it 'captures known sequences' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = @contest.flights.where( :name => 'Known', :category_id => cat.id).first
      flight.should_not be_nil
      pilot = Member.where(:family_name => 'Ernewein').first
      pilot.should_not be_nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be_nil
      sequence = pilot_flight.sequence
      sequence.should_not be_nil
      sequence.figure_count.should == 11
      sequence.total_k.should == 130
      sequence.k_values.should == [17, 7, 4, 14, 15, 16, 14, 17, 10, 10, 6]
    end
    it 'captures free sequences' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = @contest.flights.where( :name => 'Free', :category_id => cat.id).first
      flight.should_not be_nil
      pilot = Member.where(:family_name => 'Ernewein').first
      pilot.should_not be_nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be_nil
      sequence = pilot_flight.sequence
      sequence.should_not be_nil
      sequence.figure_count.should == 11
      sequence.total_k.should == 133
      sequence.k_values.should == [6, 15, 21, 16, 8, 16, 15, 14, 12, 4, 6]
    end
    it 'captures sportsman second free sequences' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = @contest.flights.where( :name => 'Unknown', :category_id => cat.id).first
      flight.should_not be_nil
      pilot = Member.where(:family_name => 'Ernewein').first
      pilot.should_not be_nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be_nil
      sequence = pilot_flight.sequence
      sequence.should_not be_nil
      sequence.figure_count.should == 11
      sequence.total_k.should == 133
      sequence.k_values.should == [6, 15, 21, 16, 8, 16, 15, 14, 12, 4, 6]
    end
    it 'captures unknown sequences' do
      cat = Category.find_for_cat_aircat('Unlimited', 'P')
      flight = @contest.flights.where( :name => 'Unknown', :category_id => cat.id).first
      flight.should_not be_nil
      pilot = Member.where(:iac_id => '13721').first
      pilot.should_not be_nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be_nil
      sequence = pilot_flight.sequence
      sequence.should_not be_nil
      sequence.figure_count.should == 14
      sequence.total_k.should == 420
      sequence.k_values.should == [36, 31, 36, 33, 41, 42, 31, 26, 24, 20, 38, 25, 17, 20]
    end
    it 'captures second unknown sequences' do
      cat = Category.find_for_cat_aircat('Intermediate', 'P')
      flight = @contest.flights.where( :name => 'Unknown II', :category_id => cat.id).first
      flight.should_not be_nil
      pilot = Member.where(:iac_id => '10467').first
      pilot.should_not be_nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be_nil
      sequence = pilot_flight.sequence
      sequence.should_not be_nil
      sequence.figure_count.should == 16
      sequence.total_k.should == 198
      sequence.k_values.should == [10, 13, 10, 13, 4, 19, 18, 14, 19, 3, 17, 10, 19, 9, 12, 8]
    end
    it 'captures scores' do
      cat = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = @contest.flights.where( :name => 'Free', :category_id => cat.id).first
      flight.should_not be_nil
      pilot = Member.where(:family_name => 'Ernewein').first
      pilot.should_not be_nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be_nil
      judge = Member.where(:family_name => 'Langworthy').first
      judge.should_not be_nil
      assist = Member.where(:family_name => 'Comat').first
      assist.should_not be_nil
      judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
      scores = pilot_flight.scores.where(:judge_id => judge_team).first
      scores.should_not be_nil
      scores.values.should == 
        [90, 95, 95, 90, 95, 90, 85, 95, 75, 90, 85]
    end
  end
end
