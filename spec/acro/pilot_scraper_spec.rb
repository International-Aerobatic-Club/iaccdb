module ACRO
  describe PilotScraper do
    describe "Reads FPS annotated reports" do
      it 'ignores 60% annotation' do
        @ps = PilotScraper.new(data_sample_file('pilot_p034s03.htm'))
        expect(@ps.score(1,1)).to eq(60)
        expect(@ps.score(3,2)).to eq(0)
        expect(@ps.score(3,8)).to eq(45)
        expect(@ps.score(14,7)).to eq(55)
      end
    end
    describe "2011 not FPS" do
      before(:all) do
        @ps = PilotScraper.new(contest_data_file('pilot_p001s16.htm'))
      end
      it 'finds the pilot flight file' do
        expect(@ps.pilotID).to eq(1)
        expect(@ps.flightID).to eq(16)
      end
      it 'finds the pilot and sequence names' do
        expect(@ps.pilotName).to eq('Kelly Adams')
        expect(@ps.flightName).to eq('Advanced - Power : Known Power')
      end
      it 'finds the judges in the flight file' do
        aj = @ps.judges
        expect(aj.length).to eq(7)
        expect(aj[0]).to eq('Debby Rihn-Harvey')
        expect(aj[6]).to eq('Bill Denton')
      end
      it 'finds the k factors for the flight' do
        ak = @ps.k_factors
        expect(ak.length).to eq(10)
        expect(ak[0]).to eq(41)
        expect(ak[4]).to eq(31)
        expect(ak[9]).to eq(12)
      end
      it 'finds scores for figures' do
        expect(@ps.score(1,3)).to eq(65)
        expect(@ps.score(1,7)).to eq(85)
        expect(@ps.score(5,3)).to eq(0)
        expect(@ps.score(10,7)).to eq(90)
      end
      it 'finds penalty amount for flight' do
        expect(@ps.penalty).to eq(20)
      end
    end
    it 'finds the no penalty amount for the flight' do
      @ps = PilotScraper.new(contest_data_file('pilot_p002s17.htm'))
      expect(@ps.penalty).to eq(0)
    end
    describe "2012 FPS" do
      before(:all) do
        @ps = PilotScraper.new(contest_data_file('pilot_p035s09.htm'))
      end
      it 'finds the pilot flight file' do
        expect(@ps.pilotID).to eq(35)
        expect(@ps.flightID).to eq(9)
      end
      it 'finds the pilot and sequence names' do
        expect(@ps.pilotName).to eq('Rob Holland')
        expect(@ps.flightName).to eq('Unlimited Power : 1st Unknown Sequence')
      end
      it 'finds the judges in the flight file' do
        aj = @ps.judges
        expect(aj.length).to eq(7)
        expect(aj[0]).to eq('Chris Rudd')
        expect(aj[6]).to eq('Mike Forney')
      end
      it 'finds the k factors for the flight' do
        ak = @ps.k_factors
        expect(ak.length).to eq(14)
        expect(ak[0]).to eq(57)
        expect(ak[4]).to eq(16)
        expect(ak[9]).to eq(37)
        expect(ak[13]).to eq(20)
      end
      it 'finds scores for figures' do
        expect(@ps.score(1,3)).to eq(80)
        expect(@ps.score(1,7)).to eq(90)
        expect(@ps.score(5,3)).to eq(90)
        expect(@ps.score(10,7)).to eq(95)
      end
      it 'finds penalty amount for flight' do
        expect(@ps.penalty).to eq(90)
      end
    end

    describe "2014 FPS" do
      before(:all) do
        @ps = PilotScraper.new(data_sample_file('pilot_p006s28.htm'))
      end
      it 'finds the pilot flight file' do
        expect(@ps.pilotID).to eq(6)
        expect(@ps.flightID).to eq(28)
      end
      it 'finds the pilot and sequence names' do
        expect(@ps.pilotName).to eq('Michael Gallaway')
        expect(@ps.flightName).to eq('Unlimited - Power : Free Unknown Sequence')
      end
      it 'finds the judges in the flight file' do
        aj = @ps.judges
        expect(aj.length).to eq(7)
        expect(aj[0]).to eq('Steve Johnson')
        expect(aj[6]).to eq('Doug Sowder')
      end
      it 'finds the k factors for the flight' do
        ak = @ps.k_factors
        expect(ak.length).to eq(15)
        expect(ak[0]).to eq(45)
        expect(ak[4]).to eq(49)
        expect(ak[9]).to eq(45)
        expect(ak[14]).to eq(20)
      end
      it 'finds scores for figures' do
        expect(@ps.score(1,3)).to eq(80)
        expect(@ps.score(1,7)).to eq(90)
        expect(@ps.score(5,3)).to eq(60)
        expect(@ps.score(10,7)).to eq(75)
      end
      it 'finds hard zeros' do
        expect(@ps.score(4,1)).to eq(IAC::Constants::HARD_ZERO)
        expect(@ps.score(4,7)).to eq(IAC::Constants::HARD_ZERO)
      end
      it 'finds averages' do
        expect(@ps.score(8,1)).to eq(IAC::Constants::AVERAGE)
        expect(@ps.score(11,6)).to eq(IAC::Constants::AVERAGE)
      end
      it 'finds penalty amount for flight' do
        expect(@ps.penalty).to eq(120)
      end
    end

    describe 'Pilot and aircraft parsing' do
      before(:all) do
        @ps = PilotScraper.new(contest_data_file('pilot_p001s16.htm'))
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
      it 'parses "Debby Rihn-Harvey - XtremeAir  DEFXA"' do
        @ps.parsePilotAircraft('Debby Rihn-Harvey - XtremeAir  DEFXA')
        expect(@ps.aircraft).to eq 'XtremeAir'
        expect(@ps.pilotName).to eq 'Debby Rihn-Harvey'
        expect(@ps.registration).to eq 'DEFXA'
      end
      it 'parses "Aaron McCartan (USA) - S-330P N-330LS"' do
        @ps.parsePilotAircraft('Aaron McCartan (USA) - S-330P N-330LS')
        expect(@ps.aircraft).to eq 'S-330P'
        expect(@ps.pilotName).to eq 'Aaron McCartan'
        expect(@ps.registration).to eq 'N-330LS'
      end
    end
  end
end
