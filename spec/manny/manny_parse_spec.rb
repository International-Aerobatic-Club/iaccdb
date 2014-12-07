module Manny
  describe Parse do
    before(:all) do 
      @manny = Manny::Parse.new
      IO.foreach('spec/manny/Contest_300.txt') { |line| @manny.processLine(line) }
      @contest = @manny.contest
    end
    it 'captures a contest' do
      expect(@contest).not_to be nil
      expect(@contest.manny_date.day).to eq(27)
      expect(@contest.manny_date.year).to eq(2010)
      expect(@contest.manny_date.month).to eq(10)
      expect(@contest.record_date.day).to eq(22)
      expect(@contest.record_date.year).to eq(2010)
      expect(@contest.record_date.month).to eq(10)
      expect(@contest.name).to eq('Phil Schacht Aerobatic Finale 2010')
      expect(@contest.region).to eq('SouthEast')
      expect(@contest.director).to eq('Charlie Wilkinson')
      expect(@contest.city).to eq('Keystone Heights')
      expect(@contest.state).to eq('FL')
      expect(@contest.chapter).to eq('288')
      expect(@contest.aircat).to eq('P')
    end
    it 'captures sequences' do
      seq = @contest.seq_for(1,1,0)
      expect(seq.figs).to eq([nil, 7, 15, 14, 10, 4, 10, 3])
      expect(seq.pres).to eq(3)
      expect(seq.ctFigs).to eq(6)
      seq = @contest.seq_for(2,2,26)
      expect(seq.figs).to eq([nil, 11, 17, 10, 13, 18, 3, 18, 11, 6, 9, 4, 10, 7, 6])
      expect(seq.pres).to eq(6)
      expect(seq.ctFigs).to eq(13)
      seq = @contest.seq_for(2,2,0)
      expect(seq.figs).to eq([nil, 7, 13, 16, 13, 19, 18, 13, 10, 18, 10, 6])
      expect(seq.pres).to eq(6)
      expect(seq.ctFigs).to eq(10)
    end
    it 'captures scores' do
      spnKnown = @contest.flight(2,1)
      spnKnown.scores.each do |s|
        seqK = spnKnown.seq_for(s.pilot)
        if s.pilot == 12 && s.judge == 7
          expect(s.seq.figs).to eq([nil, 95, 85, 80, 85, 85, 80, 90, 85, 90,
          95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) 
        end
      end
    end
    it 'captures participants' do
      part = @contest.participants[1]
      expect(part.givenName).to eq('Frederick')
      expect(part.familyName).to eq('Weaver')
      expect(part.iacID).to eq(1017)
      part = @contest.participants[37]
      expect(part.givenName).to eq('Charlie')
      expect(part.familyName).to eq('Wilkinson')
      expect(part.iacID).to eq(433543)
      category = @contest.category(2)
      pilot = category.pilot(12)
      expect(pilot.chapter).to eq('288')
      expect(pilot.make).to eq('Pitts')
      expect(pilot.model).to eq('S2B')
      expect(pilot.reg).to eq('N260AB')
    end
  end
end
