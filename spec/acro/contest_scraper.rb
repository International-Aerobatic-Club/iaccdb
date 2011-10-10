require 'spec_helper'
require 'acro/contestScraper'

module ACRO
  describe ContestScraper do
    it 'creates a new contest' do
      ct = Contest.where(:start => '2011-09-25')
      ct.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ct = Contest.where(:start => '2011-09-25').first
      cs.dContest.should == ct
    end
    it 'finds an existing contest' do
      ec = Factory(:existing_contest)
      cs = ContestScraper.new('spec/acro/existingContest.yml')
      cs.dContest.should == ec
    end
    it 'finds missing data' do
      lambda { 
        ContestScraper.new('spec/acro/faultyContest.yml')
      }.should raise_error('Missing data for contest city')
    end
    it 'finds pilot data files' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      cs.files.size.should == 6
      File.exist?(cs.files.first).should == true
      File.file?(cs.files.first).should == true
    end
    it 'creates judge member records' do
      md = Member.where(:given_name => 'Debby')
      md.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new(cs.files.first)
      cs.process_pilotFlight(ps)
      mr = Member.where(:family_name => 'Rihn-Harvey').first
      md = Member.where(:given_name => 'Debby').first
      mr.should == md
    end
    it 'finds existing judge members' do
    end
    it 'creates pilot member records' do
      md = Member.where(:given_name => 'Kelly')
      md.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new(cs.files.first)
      cs.process_pilotFlight(ps)
      mr = Member.where(:given_name => 'Kelly').first
      md = Member.where(:family_name => 'Adams').first
      mr.should == md
    end
    it 'finds existing pilot members' do
    end
    it 'creates flight records' do
      ct = Contest.where(:start => '2011-09-25')
      ct.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new(cs.files.first)
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fla = ct.flights
      fla.size.should == 1
      fl = fla.first
      fl.category.should == 'Advanced'
      fl.name.should == 'Known'
      pts = fl.pilot_flights
      pts.size.should == 1
      pt = pts.first
      pi = pt.pilot
      pi.given_name.should == 'Bryan'
      pi.family_name.should == 'Taylor'
      fjs = pt.gatherScores
      fjs[1][1].should == 80
      fjs[7][10].should == 90
      fjs[3][5].should == 0
      fjs[5][7].should == 85
    end
    it 'adds to existing flight records' do
      # make the advanced known flight exist
    end
  end
end
