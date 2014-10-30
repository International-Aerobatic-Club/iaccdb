require 'spec_helper'
#require 'acro/pilotScraper'

module ACRO
  describe PilotScraper do
    describe "Reads FPS annotated reports" do
      it 'ignores 60% annotation' do
        @ps = PilotScraper.new('spec/acro/pilot_p034s03.htm')
        @ps.score(1,1).should == 60
        @ps.score(3,2).should == 0
        @ps.score(3,8).should == 45
        @ps.score(14,7).should == 55
      end
    end
    describe "2011 not FPS" do
      before(:all) do
        @ps = PilotScraper.new('spec/acro/pilot_p001s16.htm')
      end
      it 'finds the pilot flight file' do
        @ps.pilotID.should == 1
        @ps.flightID.should == 16
      end
      it 'finds the pilot and sequence names' do
        @ps.pilotName.should == 'Kelly Adams'
        @ps.flightName.should == 'Advanced - Power : Known Power'
      end
      it 'finds the judges in the flight file' do
        aj = @ps.judges
        aj.length.should == 7
        aj[0].should == 'Debby Rihn-Harvey'
        aj[6].should == 'Bill Denton'
      end
      it 'finds the k factors for the flight' do
        ak = @ps.k_factors
        ak.length.should == 10
        ak[0].should == 41
        ak[4].should == 31
        ak[9].should == 12
      end
      it 'finds scores for figures' do
        @ps.score(1,3).should == 65
        @ps.score(1,7).should == 85
        @ps.score(5,3).should == 0
        @ps.score(10,7).should == 90
      end
      it 'finds penalty amount for flight' do
        @ps.penalty.should == 20
      end
    end
    it 'finds the no penalty amount for the flight' do
      @ps = PilotScraper.new('spec/acro/pilot_p002s17.htm')
      @ps.penalty.should == 0
    end
    describe "2012 FPS" do
      before(:all) do
        @ps = PilotScraper.new('spec/acro/pilot_p035s09.htm')
      end
      it 'finds the pilot flight file' do
        @ps.pilotID.should == 35
        @ps.flightID.should == 9
      end
      it 'finds the pilot and sequence names' do
        @ps.pilotName.should == 'Rob Holland'
        @ps.flightName.should == 'Unlimited Power : 1st Unknown Sequence'
      end
      it 'finds the judges in the flight file' do
        aj = @ps.judges
        aj.length.should == 7
        aj[0].should == 'Chris Rudd'
        aj[6].should == 'Mike Forney'
      end
      it 'finds the k factors for the flight' do
        ak = @ps.k_factors
        ak.length.should == 14
        ak[0].should == 57
        ak[4].should == 16
        ak[9].should == 37
        ak[13].should == 20
      end
      it 'finds scores for figures' do
        @ps.score(1,3).should == 80
        @ps.score(1,7).should == 90
        @ps.score(5,3).should == 90
        @ps.score(10,7).should == 95
      end
      it 'finds penalty amount for flight' do
        @ps.penalty.should == 90
      end
    end

    describe "2014 FPS" do
      before(:all) do
        @ps = PilotScraper.new('spec/acro/pilot_p006s28.htm')
      end
      it 'finds the pilot flight file' do
        @ps.pilotID.should == 6
        @ps.flightID.should == 28
      end
      it 'finds the pilot and sequence names' do
        @ps.pilotName.should == 'Michael Gallaway'
        @ps.flightName.should == 'Unlimited - Power : Free Unknown Sequence'
      end
      it 'finds the judges in the flight file' do
        aj = @ps.judges
        aj.length.should == 7
        aj[0].should == 'Steve Johnson'
        aj[6].should == 'Doug Sowder'
      end
      it 'finds the k factors for the flight' do
        ak = @ps.k_factors
        ak.length.should == 15
        ak[0].should == 45
        ak[4].should == 49
        ak[9].should == 45
        ak[14].should == 20
      end
      it 'finds scores for figures' do
        @ps.score(1,3).should == 80
        @ps.score(1,7).should == 90
        @ps.score(5,3).should == 60
        @ps.score(10,7).should == 75
      end
      it 'finds penalty amount for flight' do
        @ps.penalty.should == 120
      end
    end

    describe 'Pilot and aircraft parsing' do
      before(:all) do
        @ps = PilotScraper.new('spec/acro/pilot_p001s16.htm')
      end
      it 'parses "Paul Thomson - Decathlon N725JM"' do
        @ps.parsePilotAircraft('Paul Thomson - Decathlon N725JM')
        expect(@ps.aircraft).to eq 'Decathlon'
        expect(@ps.pilotName).to eq 'Paul Thomson'
        expect(@ps.registration).to eq 'N725JM'
      end
      it 'parses "Sean Van Hatten - Decathlon N210XD"' do
        @ps.parsePilotAircraft('Sean Van Hatten - Decathlon N210XD')
        expect(@ps.aircraft).to eq 'Decathlon'
        expect(@ps.pilotName).to eq 'Sean Van Hatten'
        expect(@ps.registration).to eq 'N210XD'
      end
      it 'parses " Michael Gallaway - Extra 300 SX N540BG "' do
        @ps.parsePilotAircraft(' Michael Gallaway - Extra 300 SX N540BG ')
        expect(@ps.aircraft).to eq 'Extra 300 SX'
        expect(@ps.pilotName).to eq 'Michael Gallaway'
        expect(@ps.registration).to eq 'N540BG'
      end
      it 'parses "Kelly Adams  Staudacher 300D  N804Q"' do
        @ps.parsePilotAircraft('Kelly Adams  Staudacher 300D  N804Q')
        expect(@ps.aircraft).to eq 'Staudacher 300D'
        expect(@ps.pilotName).to eq 'Kelly Adams'
        expect(@ps.registration).to eq 'N804Q'
      end
      it 'parses "John Owens - Pitts S-2B  N549JE"' do
        @ps.parsePilotAircraft('John Owens - Pitts S-2B  N549JE')
        expect(@ps.aircraft).to eq 'Pitts S-2B'
        expect(@ps.pilotName).to eq 'John Owens'
        expect(@ps.registration).to eq 'N549JE'
      end
      it 'parses "Debby Rihn-Harvey - Pitts S-2B N123RH"' do
        @ps.parsePilotAircraft('Debby Rihn-Harvey - Pitts S-2B N123RH')
        expect(@ps.aircraft).to eq 'Pitts S-2B'
        expect(@ps.pilotName).to eq 'Debby Rihn-Harvey'
        expect(@ps.registration).to eq 'N123RH'
      end
    end
  end
end
