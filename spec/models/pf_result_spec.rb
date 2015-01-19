module Model
  describe PfResult, :type => :model do
    context 'real_scores' do
      before(:each) do
        @category = Category.find_by_category_and_aircat('intermediate', 'P')
        @pilot_flight = create(:adams_known)
        judge_team = create(:judge_klein)
        create(:adams_known_klein, 
          :pilot_flight => @pilot_flight,
          :judge => judge_team)
        @judge_jim = create(:judge_jim)
        create(:adams_known_jim, 
          :pilot_flight => @pilot_flight,
          :judge => @judge_jim)
        judge_team = create(:judge_lynne)
        create(:adams_known_lynne, 
          :pilot_flight => @pilot_flight,
          :judge => judge_team)
        @pf = @pilot_flight.results
      end
      it 'finds judges' do
        judge_teams = @pf.judge_teams
        expect(judge_teams.length).to eq(3)
        expect(judge_teams.include?(@judge_jim)).to eq(true)
      end
      it 'computes and caches figure and flight values' do
        pf_update = @pf.updated_at
        pfj = @pf.for_judge(@judge_jim)
        expect(pfj.computed_values).to eq( 
          [2090, 1000, 1400, 1530, 1620, 2125, 2125,
           1400, 900, 1440, 1105, 510, 360, 760]
        )
        expect(pfj.flight_value).to eq(18365)
        expect(@pf.flight_value).to eq(1789)
        pfn = @pilot_flight.results
        expect(pf_update <= pfn.updated_at).to eq true
      end
      it 'updates cached values when scores change' do
        scores = @pilot_flight.scores.where(:judge_id => @judge_jim).first
        va = scores.values
        va[3] = 80
        va[12] = 100
        expect(scores.save).to eq(true)
        contest = Contest.where(:start => '2011-09-25').first
        expect(contest).not_to be nil
        flight = contest.flights.first
        expect(flight).not_to be nil
        pilot = Member.find_by_iac_id(1999)
        expect(pilot).not_to be nil
        @pilot_flight = PilotFlight.where(
          :pilot_id => pilot.id, 
          :flight_id => flight.id).first
        expect(@pilot_flight).not_to be nil
        pf = @pilot_flight.results
        pfj = pf.for_judge(@judge_jim)
        expect(pfj).not_to be nil
        expect(pfj.computed_values).to eq( 
          [2090, 1000, 1400, 1360, 1620, 2125, 2125,
           1400, 900, 1440, 1105, 510, 400, 760]
        )
        expect(pfj.flight_value).to eq(18235)
        expect(pf.flight_value.round(2)).to eq(1784.67)
      end
      it 'updates cached values when sequence changes' do
        @pilot_flight.sequence.k_values[13] = 12
        expect(@pilot_flight.sequence.save).to eq(true)
        contest = Contest.where(:start => '2011-09-25').first
        expect(contest).not_to be nil
        flight = contest.flights.first
        expect(flight).not_to be nil
        pilot = Member.find_by_iac_id(1999)
        expect(pilot).not_to be nil
        @pilot_flight = PilotFlight.where(
          :pilot_id => pilot.id, 
          :flight_id => flight.id).first
        expect(@pilot_flight).not_to be nil
        pf = @pilot_flight.results
        expect(pf.flight_value.round(2)).to eq(1827)
      end
      it 'logs error if k values for some but not for all' do
        @pilot_flight.sequence.k_values.pop
        expect(@pilot_flight.sequence.save).to eq(true)
        expect(@pilot_flight.sequence.k_values.length).to eq(13)
        contest = Contest.where(:start => '2011-09-25').first
        expect(contest).not_to be nil
        flight = contest.flights.first
        expect(flight).not_to be nil
        pilot = Member.find_by_iac_id(1999)
        expect(pilot).not_to be nil
        @pilot_flight = PilotFlight.where(
          :pilot_id => pilot.id, 
          :flight_id => flight.id).first
        expect(@pilot_flight).not_to be nil
        logger = double()
        Rails.logger = logger
        expect(logger).to receive(:error).exactly(3).times
        @pilot_flight.results
      end
    end
    it 'behaves on empty sequence' do
      @pf = create(:pilot_flight)
      create(:score,
        :pilot_flight => @pf,
        :values => [60, 0, 0, 0, 0])
      create(:score,
        :pilot_flight => @pf,
        :values => [-10, 0, 0, 0, 0])
      @pf.results
    end
    context 'mixed grades, averages, and zeros' do
      before(:each) do
        seq = create(:sequence,
          :k_values => [2,2,2,2,2,2])
        @pf = create(:pilot_flight,
          :sequence => seq)
        @judges = []
        5.times { @judges << create(:judge) }
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[0],
          :values => [60, 0, 60, 0, 80, 0])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[1],
          :values => [-10, 0, 90, -10, -10, -10])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[2],
          :values => [80, 60, 0, 70, -10, -10])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[3],
          :values => [80, 70, 0, 80, 0, 0])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[4],
          :values => [60, 80, 0, 60, 0, 0])
        #     f0, f1, f2, f3, f4, f5
        # j0: 60, 70,  0, 70,  0,  0 = 200
        # j1: 70, 70,  0, 70,  0,  0 = 210
        # j2: 80, 60,  0, 70,  0,  0 = 210
        # j3: 80, 70,  0, 80,  0,  0 = 230
        # j4: 60, 80,  0, 60,  0,  0 = 200
        #     70, 70,  0, 70,  0,  0   210       
        @res = @pf.results
      end
      it 'converts average grade to the average' do
        expect(@res.for_judge(@judges[1]).computed_values[0]).to eq(140)
        expect(@res.figure_results[0]).to eq(140)
      end
      it 'converts minority zero to the average' do
        expect(@res.figure_results[1]).to eq(140)
      end
      it 'converts minority grade to zero' do
        expect(@res.for_judge(@judges[0]).graded_values[2]).to eq(120)
        expect(@res.for_judge(@judges[1]).graded_values[2]).to eq(180)
        expect(@res.for_judge(@judges[0]).computed_values[2]).to eq(0)
        expect(@res.for_judge(@judges[1]).computed_values[2]).to eq(0)
        expect(@res.figure_results[2]).to eq(0)
      end
      it 'converts minority zero and averages to the average' do
        expect(@res.for_judge(@judges[0]).graded_values[3]).to eq(-30)
        expect(@res.for_judge(@judges[1]).graded_values[3]).to eq(140)
        expect(@res.for_judge(@judges[0]).computed_values[3]).to eq(140)
        expect(@res.for_judge(@judges[1]).computed_values[3]).to eq(140)
        expect(@res.figure_results[3]).to eq(140)
      end
      it 'converts minority grade and averages to zero' do
        expect(@res.for_judge(@judges[0]).graded_values[4]).to eq(160)
        expect(@res.for_judge(@judges[1]).graded_values[4]).to eq(160)
        expect(@res.for_judge(@judges[2]).graded_values[4]).to eq(160)
        expect(@res.for_judge(@judges[0]).computed_values[4]).to eq(0)
        expect(@res.for_judge(@judges[1]).computed_values[4]).to eq(0)
        expect(@res.for_judge(@judges[2]).computed_values[4]).to eq(0)
        expect(@res.figure_results[4]).to eq(0)
      end
      it 'computes flight values with only zeros and averages' do
        expect(@res.for_judge(@judges[1]).graded_values[5]).to eq(0)
        expect(@res.figure_results[5]).to eq(0)
      end
      it 'computes flight values with resolved zeros and averages' do
        expect(@res.for_judge(@judges[0]).flight_value).to eq(400)
        expect(@res.for_judge(@judges[1]).flight_value).to eq(420)
        expect(@res.for_judge(@judges[2]).flight_value).to eq(420)
        expect(@res.for_judge(@judges[3]).flight_value).to eq(460)
        expect(@res.for_judge(@judges[4]).flight_value).to eq(400)
        expect(@res.flight_value.round(2)).to eq(42.0)
      end
    end
    context 'mixed grades, conference averages, averages, soft zeros, and hard zeros' do
      before(:each) do
        seq = create(:sequence,
          :k_values => [2,2,2,2,2,2,2,2,2])
        @pf = create(:pilot_flight,
          :sequence => seq)
        @judges = []
        5.times { @judges << create(:judge) }
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[0],
          :values => [-10, -10, -10,  60,  70,  80, -30, -30, -30])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[1],
          :values => [ 40,  30, -10,  80, -30, -10, -30,   0, -30])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[2],
          :values => [-30, -30, -30, -30, -30, -30,   0, -30,   0])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[3],
          :values => [-30, -20,  50, -30, -30, -30, -30,  70,   0])
        create(:score,
          :pilot_flight => @pf,
          :judge => @judges[4],
          :values => [-20, -20, -20, -20, -20, -20, -20,  80,  90])
        @res = @pf.results(true) # has soft zero
        #
        #    GRADED                    COMPUTED
        #     j1, j2, j3, j4, j5   A   j1, j2, j3, j4, j5   Avg
        # f1:  A,  4, HZ, HZ, CA : 4 :  4,  4,  4,  4,  4 =  4 =  8
        # f2:  A,  3, HZ, CA, CA : 3 :  3,  3,  3,  3,  3 =  3 =  6
        # f3:  A,  A, HZ,  5, CA : 5 :  5,  5,  5,  5,  5 =  5 = 10
        # f4:  6,  8, HZ, HZ, CA : 7 :  6,  8,  7,  7,  7 =  7 = 14 
        # f5:  7, HZ, HZ, HZ, CA : 0 :  0,  0,  0,  0,  0 =  0 =  0
        # f6:  8,  A, HZ, HZ, CA : 8 :  8,  8,  8,  8,  8 =  8 = 16
        # f7: HZ, HZ,  0, HZ, CA : 0 :  0,  0,  0,  0,  0 =  0 =  0
        # f8: HZ,  0, HZ,  7,  8 : 5 :  5,  0,  5,  7,  8 =  5 = 10
        # f9: HZ, HZ,  0,  0,  9 : 3 :  3,  3,  0,  0,  9 =  5 = 10
        #                              68, 62, 64, 68, 88 = 70   74       
        #
      end
      it 'converts A, 4, HZ, HZ, CA to 4 (one grade, two averages, minority HZ)' do
        expect(@res.for_judge(@judges[0]).computed_values[0]).to eq(80)
        expect(@res.for_judge(@judges[1]).computed_values[0]).to eq(80)
        expect(@res.for_judge(@judges[2]).computed_values[0]).to eq(80)
        expect(@res.for_judge(@judges[3]).computed_values[0]).to eq(80)
        expect(@res.for_judge(@judges[4]).computed_values[0]).to eq(80)
        expect(@res.figure_results[0]).to eq(80)
      end
      it 'converts A, 3, HZ, CA, CA to 3 (one grade, three averages, minority HZ)' do
        expect(@res.for_judge(@judges[0]).computed_values[1]).to eq(60)
        expect(@res.for_judge(@judges[1]).computed_values[1]).to eq(60)
        expect(@res.for_judge(@judges[2]).computed_values[1]).to eq(60)
        expect(@res.for_judge(@judges[3]).computed_values[1]).to eq(60)
        expect(@res.for_judge(@judges[4]).computed_values[1]).to eq(60)
        expect(@res.figure_results[1]).to eq(60)
      end
      it 'converts A, A, HZ, 5, CA to 5 (one grade, three avereges, minority HZ)' do
        expect(@res.for_judge(@judges[0]).computed_values[2]).to eq(100)
        expect(@res.for_judge(@judges[1]).computed_values[2]).to eq(100)
        expect(@res.for_judge(@judges[2]).computed_values[2]).to eq(100)
        expect(@res.for_judge(@judges[3]).computed_values[2]).to eq(100)
        expect(@res.for_judge(@judges[4]).computed_values[2]).to eq(100)
        expect(@res.figure_results[2]).to eq(100)
      end
      it 'converts 6, 8, HZ, HZ, CA to 6, 8, 7, 7, 7 (minority zero due to CA)' do
        expect(@res.for_judge(@judges[0]).computed_values[3]).to eq(120)
        expect(@res.for_judge(@judges[1]).computed_values[3]).to eq(160)
        expect(@res.for_judge(@judges[2]).computed_values[3]).to eq(140)
        expect(@res.for_judge(@judges[3]).computed_values[3]).to eq(140)
        expect(@res.for_judge(@judges[4]).computed_values[3]).to eq(140)
        expect(@res.figure_results[3]).to eq(140)
      end
      it 'converts 7, HZ, HZ, HZ, CA to 0 (majority zero)' do
        expect(@res.for_judge(@judges[0]).computed_values[4]).to eq(0)
        expect(@res.for_judge(@judges[1]).computed_values[4]).to eq(0)
        expect(@res.for_judge(@judges[2]).computed_values[4]).to eq(0)
        expect(@res.for_judge(@judges[3]).computed_values[4]).to eq(0)
        expect(@res.for_judge(@judges[4]).computed_values[4]).to eq(0)
        expect(@res.figure_results[4]).to eq(0)
      end
      it 'converts 8, A, HZ, HZ, CA to 8 (one grade, minority zero due to A and CA)' do
        expect(@res.for_judge(@judges[0]).computed_values[5]).to eq(160)
        expect(@res.for_judge(@judges[1]).computed_values[5]).to eq(160)
        expect(@res.for_judge(@judges[2]).computed_values[5]).to eq(160)
        expect(@res.for_judge(@judges[3]).computed_values[5]).to eq(160)
        expect(@res.for_judge(@judges[4]).computed_values[5]).to eq(160)
        expect(@res.figure_results[5]).to eq(160)
      end
      it 'converts HZ, HZ, 0, HZ, CA to 0 (majority zero with soft zero and CA)' do
        expect(@res.for_judge(@judges[0]).computed_values[6]).to eq(0)
        expect(@res.for_judge(@judges[1]).computed_values[6]).to eq(0)
        expect(@res.for_judge(@judges[2]).computed_values[6]).to eq(0)
        expect(@res.for_judge(@judges[3]).computed_values[6]).to eq(0)
        expect(@res.for_judge(@judges[4]).computed_values[6]).to eq(0)
        expect(@res.figure_results[6]).to eq(0)
      end
      it 'converts HZ, 0, HZ, 7, 8 to 5, 0, 5, 7, 8 (minority zero with soft zero in average)' do
        expect(@res.for_judge(@judges[0]).computed_values[7]).to eq(100)
        expect(@res.for_judge(@judges[1]).computed_values[7]).to eq(0)
        expect(@res.for_judge(@judges[2]).computed_values[7]).to eq(100)
        expect(@res.for_judge(@judges[3]).computed_values[7]).to eq(140)
        expect(@res.for_judge(@judges[4]).computed_values[7]).to eq(160)
        expect(@res.figure_results[7]).to eq(100)
      end
      it 'converts HZ, HZ, 0, 0, 9 to 3, 3, 0, 0, 9 (minority zero with two soft zero in average)' do
        expect(@res.for_judge(@judges[0]).computed_values[8]).to eq(60)
        expect(@res.for_judge(@judges[1]).computed_values[8]).to eq(60)
        expect(@res.for_judge(@judges[2]).computed_values[8]).to eq(0)
        expect(@res.for_judge(@judges[3]).computed_values[8]).to eq(0)
        expect(@res.for_judge(@judges[4]).computed_values[8]).to eq(180)
        expect(@res.figure_results[8]).to eq(60)
      end
    end
  end
end
