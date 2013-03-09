require 'spec_helper'
#require 'iac/mannyParse'

module Manny
  describe Parse do
    before(:all) do 
      @manny = Manny::Parse.new
      IO.foreach('spec/manny/Contest_300.txt') { |line| @manny.processLine(line) }
      @contest = @manny.contest
    end
    it 'captures a contest' do
      @contest.should_not be nil
      @contest.manny_date.day.should == 27
      @contest.manny_date.year.should == 2010
      @contest.manny_date.month.should == 10
      @contest.record_date.day.should == 22
      @contest.record_date.year.should == 2010
      @contest.record_date.month.should == 10
      @contest.name.should == 'Phil Schacht Aerobatic Finale 2010'
      @contest.region.should == 'SouthEast'
      @contest.director.should == 'Charlie Wilkinson'
      @contest.city.should == 'Keystone Heights'
      @contest.state.should == 'FL'
      @contest.chapter.should == '288'
      @contest.aircat.should == 'P'
    end
    it 'captures sequences' do
      seq = @contest.seq_for(1,1,0)
      seq.figs.should ==  [nil, 7, 15, 14, 10, 4, 10, 3]
      seq.pres.should == 3
      seq.ctFigs.should == 6
      seq = @contest.seq_for(2,2,26)
      seq.figs.should ==  [nil, 11, 17, 10, 13, 18, 3, 18, 11, 6, 9, 4, 10, 7, 6]
      seq.pres.should == 6
      seq.ctFigs.should == 13
      seq = @contest.seq_for(2,2,0)
      seq.figs.should ==  [nil, 7, 13, 16, 13, 19, 18, 13, 10, 18, 10, 6]
      seq.pres.should == 6
      seq.ctFigs.should == 10
    end
    it 'captures scores' do
      spnKnown = @contest.flight(2,1)
      spnKnown.scores.each do |s|
        seqK = spnKnown.seq_for(s.pilot)
        if s.pilot == 12 && s.judge == 7
          s.seq.figs.should == [nil, 95, 85, 80, 85, 85, 80, 90, 85, 90,
          95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] 
        end
      end
    end
    it 'captures participants' do
      part = @contest.participants[1]
      part.givenName.should == 'Frederick'
      part.familyName.should == 'Weaver'
      part.iacID.should == 1017
      part = @contest.participants[37]
      part.givenName.should == 'Charlie'
      part.familyName.should == 'Wilkinson'
      part.iacID.should == 433543
      category = @contest.category(2)
      pilot = category.pilot(12)
      pilot.chapter.should == '288'
      pilot.make.should == 'Pitts'
      pilot.model.should == 'S2B'
      pilot.reg.should == 'N260AB'
    end
  end
end
