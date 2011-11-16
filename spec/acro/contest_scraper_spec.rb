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
      ps = PilotScraper.new('spec/acro/pilot_p002s17.htm')
      cs.process_pilotFlight(ps)
      mr = Member.where(:family_name => 'Rihn-Harvey').first
      md = Member.where(:given_name => 'Debby').first
      mr.should == md
    end
    it 'finds existing judge members' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      cs.files.each do |pf|
        ps = PilotScraper.new(pf)
        cs.process_pilotFlight(ps)
      end
      Judge.all.size.should == 14
      stols = Member.where(:family_name => 'Stoltenberg')
      stols.size.should == 1
      aj = Judge.where(:judge_id => stols.first)
      aj.size.should == 1
    end
    it 'creates pilot member records' do
      md = Member.where(:given_name => 'Kelly')
      md.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new('spec/acro/pilot_p002s17.htm')
      cs.process_pilotFlight(ps)
      mr = Member.where(:given_name => 'Kelly').first
      md = Member.where(:family_name => 'Adams').first
      mr.should == md
    end
    it 'finds existing pilot members' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      cs.files.each do |pf|
        ps = PilotScraper.new(pf)
        cs.process_pilotFlight(ps)
      end
      ballews = Member.where(:family_name => 'Ballew').all
      ballews.size.should == 1
      apf = PilotFlight.where(:pilot_id => ballews.first)
      apf.size.should == 2
    end
    it 'creates flight records' do
      ct = Contest.where(:start => '2011-09-25')
      ct.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new('spec/acro/pilot_p002s17.htm')
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fla = ct.flights
      fla.size.should == 1
      fl = fla.first
      fl.category.should == 'Advanced'
      fl.aircat.should == 'P'
      fl.name.should == 'Free'
      pts = fl.pilot_flights
      pts.size.should == 1
      pt = pts.first
      pi = pt.pilot
      pi.given_name.should == 'Bruce'
      pi.family_name.should == 'Ballew'
      fjs = pt.gatherScores
      fjs[1][1].should == 85
      fjs[10][7].should == 90
      fjs[5][3].should == 80
      fjs[7][5].should == 85
      fjs[10][3].should == 60
      fjs[12][4].should == 85
      fjs[13][2].should == 70
    end
    it 'adds to existing flight records' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      cs.files.each do |pf|
        ps = PilotScraper.new(pf)
        cs.process_pilotFlight(ps)
      end
      ct = Contest.where(:start => '2011-09-25').first
      fla = ct.flights
      fla.size.should == 3
      fla.first.pilot_flights.size.should == 2
    end
    it 'stores the penalty' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new('spec/acro/pilot_p002s17.htm')
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fl = ct.flights.first
      pf = fl.pilot_flights.first
      pf.penalty_total.should == 0
      ps = PilotScraper.new('spec/acro/pilot_p002s16.htm')
      cs.process_pilotFlight(ps)
      fl = ct.flights[1]
      pf = fl.pilot_flights.first
      pf.penalty_total.should == 110
    end
    it 'stores figure k values' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ps = PilotScraper.new('spec/acro/pilot_p002s17.htm')
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fl = ct.flights.first
      pf = fl.pilot_flights.first
      seq = pf.sequence
      seq.total_k.should == 312
      seq.figure_count.should == 13
      seq.k_values[0].should == 40
      seq.k_values[9].should == 22
      seq.k_values[12].should == 12
    end
  end
end
