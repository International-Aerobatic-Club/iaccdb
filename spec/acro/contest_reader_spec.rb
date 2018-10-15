module ACRO

  describe ContestReader do
    before :context do
      setup_contest_extracted_data
    end

    after :context do
      cleanup_contest_extracted_data
    end

    it 'creates a new contest' do
      ct = Contest.where(:start => '2011-09-25')
      expect(ct.empty?).to eq(true)
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      ct = Contest.where(:start => '2011-09-25').first
      expect(cs.contest_record).to eq(ct)
    end

    it 'finds an existing contest' do
      ec = create(:existing_contest)
      cs = ContestReader.new(contest_data_file('existingContest.yml'))
      expect(cs.contest_record).to eq(ec)
    end

    it 'finds missing data' do
      expect { 
        ContestReader.new(contest_data_file('faultyContest.yml'))
      }.to raise_error('Missing data for contest city')
    end

    it 'creates judge member records' do
      md = Member.where(:given_name => 'Debby')
      expect(md.empty?).to eq(true)
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      ps = PilotScraper.new(contest_data_file('pilot_p002s17.htm'))
      cs.process_pilotFlight(ps)
      mr = Member.where(:family_name => 'Rihn-Harvey').first
      md = Member.where(:given_name => 'Debby').first
      expect(mr).to eq(md)
    end

    it 'finds existing judge members' do
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      cs.read_contest
      expect(Judge.all.size).to eq(18)
      stols = Member.where(:family_name => 'Stoltenberg')
      expect(stols.size).to eq(1)
      aj = Judge.where(:judge_id => stols.first)
      expect(aj.size).to eq(1)
    end

    it 'creates pilot member records' do
      md = Member.where(:given_name => 'Kelly')
      expect(md.empty?).to eq(true)
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      ps = PilotScraper.new(contest_data_file('pilot_p002s17.htm'))
      cs.process_pilotFlight(ps)
      mr = Member.where(:given_name => 'Kelly').first
      md = Member.where(:family_name => 'Adams').first
      expect(mr).to eq(md)
    end

    it 'finds existing pilot members' do
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      cs.read_contest
      ballews = Member.where(:family_name => 'Ballew').all
      expect(ballews.size).to eq(1)
      apf = PilotFlight.where(:pilot_id => ballews.first)
      expect(apf.size).to eq(2)
    end

    it 'creates flight records' do
      ct = Contest.where(:start => '2011-09-25')
      expect(ct.empty?).to eq(true)
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      ps = PilotScraper.new(contest_data_file('pilot_p002s17.htm'))
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fla = ct.flights
      expect(fla.size).to eq(1)
      fl = fla.first
      cat = fl.category
      expect(cat.category).to eq('advanced')
      expect(cat.aircat).to eq('P')
      expect(fl.name).to eq('Free')
      pilot_flights = fl.pilot_flights
      expect(pilot_flights.size).to eq(1)
      pilot_flight = pilot_flights.first
      pilot = pilot_flight.pilot
      expect(pilot.given_name).to eq('Bruce')
      expect(pilot.family_name).to eq('Ballew')
      scores = pilot_flight.scores
      expect(scores[0].values[0]).to eq(85)
      expect(scores[6].values[9]).to eq(90)
      expect(scores[2].values[4]).to eq(80)
      expect(scores[4].values[6]).to eq(85)
      expect(scores[2].values[9]).to eq(60)
      expect(scores[3].values[11]).to eq(85)
      expect(scores[1].values[12]).to eq(70)
    end

    it 'adds to existing flight records' do
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      cs.read_contest
      ct = Contest.where(:start => '2011-09-25').first
      fla = ct.flights
      expect(fla.size).to eq(4)
      fps = fla.collect do |f|
        f.pilot_flights.size
      end
      expect(fps).to match_array([1, 2, 2, 2])
    end

    it 'stores the penalty' do
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      ps = PilotScraper.new(contest_data_file('pilot_p002s17.htm'))
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fl = ct.flights.first
      pf = fl.pilot_flights.first
      expect(pf.penalty_total).to eq(0)
      ps = PilotScraper.new(contest_data_file('pilot_p002s16.htm'))
      cs.process_pilotFlight(ps)
      fl = ct.flights[1]
      pf = fl.pilot_flights.first
      expect(pf.penalty_total).to eq(110)
    end

    it 'stores figure k values' do
      cs = ContestReader.new(contest_data_file('newContest.yml'))
      ps = PilotScraper.new(contest_data_file('pilot_p002s17.htm'))
      cs.process_pilotFlight(ps)
      ct = Contest.where(:start => '2011-09-25').first
      fl = ct.flights.first
      pf = fl.pilot_flights.first
      seq = pf.sequence
      expect(seq.total_k).to eq(312)
      expect(seq.figure_count).to eq(13)
      expect(seq.k_values[0]).to eq(40)
      expect(seq.k_values[9]).to eq(22)
      expect(seq.k_values[12]).to eq(12)
    end
  end
end
