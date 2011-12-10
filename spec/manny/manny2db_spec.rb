require 'spec_helper'
require 'iac/mannyParse'
require 'iac/mannyToDB'

module IAC
  describe MannyToDB do
    before(:all) do 
      manny = Manny::MannyParse.new
      IO.foreach('spec/manny/Contest_300.txt') { |line| manny.processLine(line) }
      m2d = IAC::MannyToDB.new
      m2d.process_contest(manny, true)
      @contest = Contest.first
    end
    it 'captures a contest' do
      @contest.should_not be nil
      @contest.start.day.should == 22
      @contest.start.year.should == 2010
      @contest.start.month.should == 10
      @contest.name.should == 'Phil Schacht Aerobatic Finale 2010'
      @contest.region.should == 'SouthEast'
      @contest.director.should == 'Charlie Wilkinson'
      @contest.city.should == 'Keystone Heights'
      @contest.state.should == 'FL'
      @contest.chapter.should == 288
    end
    it 'captures known sequence' do
      flight = @contest.flights.first
      flight.should_not be nil
      pilot_flight = flight.pilot_flights.first
      pilot_flight.should_not be nil
      sequence = pilot_flight.sequence
      sequence.should_not be nil
      sequence.k_values.should == [7, 15, 14, 10, 4, 10, 3]
      #puts "flight is #{flight}"
      #puts "pilot is #{pilot_flight.pilot}"
      #puts "sequence is #{sequence}"
    end
    it 'captures free sequence' do
      flight = @contest.flights.where(
        :name => 'Free', 
        :category => 'Sportsman').first
      flight.should_not be nil
      pilot = Member.where(:family_name => 'Hartvigsen').first
      pilot.should_not be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be nil
      sequence = pilot_flight.sequence
      sequence.should_not be nil
      sequence.k_values.should == 
        [11, 17, 10, 13, 18, 3, 18, 11, 6, 9, 4, 10, 7, 6]
    end
    it 'captures default free sequence' do
      flight = @contest.flights.where(
        :name => 'Free', 
        :category => 'Sportsman').first
      flight.should_not be nil
      pilot = Member.where(:family_name => 'Cohen').first
      pilot.should_not be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be nil
      sequence = pilot_flight.sequence
      sequence.should_not be nil
      sequence.k_values.should == 
        [7, 13, 16, 13, 19, 18, 13, 10, 18, 10, 6]
    end
    it 'captures scores' do
      flight = @contest.flights.where(
        :name => 'Free', 
        :category => 'Sportsman').first # manny 2, 2
      flight.should_not be nil
      pilot = Member.where(:family_name => 'Cohen').first # manny_id 6
      pilot.should_not be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      pilot_flight.should_not be nil
      judge = Member.where(:family_name => 'Wells').first # manny_id 13
      judge.should_not be nil
      assist = Member.where(:family_name => 'Davis').first
      assist.should_not be nil
      judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
      scores = pilot_flight.scores.where(:judge_id => judge_team).first
      scores.should_not be nil
      scores.values.should == 
        [85, 90, 65, 100, 80, 85, 90, 100, 0, 90, 85]
    end
    it 'captures participants' do
      part = Member.where(:given_name => 'Frederick').first
      part.family_name.should == 'Weaver'
      part.iac_id.should == 1017
      part = Member.where(:family_name => 'Wilkinson').first
      part.given_name.should == 'Charlie'
      part.iac_id.should == 433543
    end
  end
end