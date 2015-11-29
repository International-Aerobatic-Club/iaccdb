# Test computation of rank values
# All of the numbers come from the spreadsheet, FlightComputation.ods
# found in this directory
module IAC
  describe RankComputer, :type => :model do
    context 'with computed contest' do
      before(:context) do
        @contest = create(:contest)
        @flight = create(:flight, :contest => @contest)
        seq = create(:sequence, :k_values => [2,2,2,2,2])
        pilot_flights = []
        [2, 6, 0, 0, 8].each do |penalty|
          pilot_flights << create(
            :pilot_flight, 
            :flight => @flight, 
            :sequence => seq, 
            :penalty_total => penalty) 
        end
        @judges = []
        4.times { @judges << create(:judge) }
        # pilot_flights[0]
        create(:score,
          :pilot_flight => pilot_flights[0],
          :judge => @judges[0],
          :values => [90, 80, 85, 75, 80])
        create(:score,
          :pilot_flight => pilot_flights[0],
          :judge => @judges[1],
          :values => [95, 80, 85, 90, 75])
        create(:score,
          :pilot_flight => pilot_flights[0],
          :judge => @judges[2],
          :values => [80, 75, 80, 75, 55])
        create(:score,
          :pilot_flight => pilot_flights[0],
          :judge => @judges[3],
          :values => [90, 75, 85, 85, 70])
        # pilot_flights[1]
        create(:score,
          :pilot_flight => pilot_flights[1],
          :judge => @judges[0],
          :values => [70, 80, 85, 80, 70])
        create(:score,
          :pilot_flight => pilot_flights[1],
          :judge => @judges[1],
          :values => [80, 85, 90, 80, 70])
        create(:score,
          :pilot_flight => pilot_flights[1],
          :judge => @judges[2],
          :values => [65, 80, 60, 75, 50])
        create(:score,
          :pilot_flight => pilot_flights[1],
          :judge => @judges[3],
          :values => [65, 60, 80, 80, 75])
        # pilot_flights[2]
        create(:score,
          :pilot_flight => pilot_flights[2],
          :judge => @judges[0],
          :values => [80, 30, 80, 85, 60])
        create(:score,
          :pilot_flight => pilot_flights[2],
          :judge => @judges[1],
          :values => [80, 60, 70, 80, 60])
        create(:score,
          :pilot_flight => pilot_flights[2],
          :judge => @judges[2],
          :values => [75, 50, 70, 80, 70])
        create(:score,
          :pilot_flight => pilot_flights[2],
          :judge => @judges[3],
          :values => [75, 30, 80, 85, 70])
        # pilot_flights[3]
        create(:score,
          :pilot_flight => pilot_flights[3],
          :judge => @judges[0],
          :values => [95, 85, 90, 90, 85])
        create(:score,
          :pilot_flight => pilot_flights[3],
          :judge => @judges[1],
          :values => [70, 85, 90, 85, 80])
        create(:score,
          :pilot_flight => pilot_flights[3],
          :judge => @judges[2],
          :values => [75, 75, 80, 75, 70])
        create(:score,
          :pilot_flight => pilot_flights[3],
          :judge => @judges[3],
          :values => [85, 85, 90, 85, 80])
        # pilot_flights[4]
        create(:score,
          :pilot_flight => pilot_flights[4],
          :judge => @judges[0],
          :values => [90, 85, 85, 90, 85])
        create(:score,
          :pilot_flight => pilot_flights[4],
          :judge => @judges[1],
          :values => [80, 85, 85, 90, 70])
        create(:score,
          :pilot_flight => pilot_flights[4],
          :judge => @judges[2],
          :values => [75, 80, 90, 85, 80])
        create(:score,
          :pilot_flight => pilot_flights[4],
          :judge => @judges[3],
          :values => [70, 80, 90, 90, 75])
        computer = ContestComputer.new(@contest)
        computer.compute_results
        flight = @contest.flights.first
        @pilot_flights = flight.pilot_flights
      end
      it 'ranks pilots for a flight' do
        [3, 4, 5, 2, 1].each_with_index do |r,i|
          expect(@pilot_flights[i].pf_results.first.flight_rank).to eq(r)
        end
        [2, 5, 4, 1, 3].each_with_index do |r,i|
          expect(@pilot_flights[i].pf_results.first.adj_flight_rank).to eq(r)
        end
      end
      it 'ranks figures for a flight' do
        res = @pilot_flights[0].pf_results.first
        expect(res.for_judge(@judges[0]).computed_ranks).to eq([2,3,2,5,3])
        expect(res.for_judge(@judges[1]).computed_ranks).to eq([1,4,3,1,2])
        expect(res.for_judge(@judges[2]).computed_ranks).to eq([1,3,2,3,4])
        expect(res.for_judge(@judges[3]).computed_ranks).to eq([1,3,3,2,4])
        res = @pilot_flights[1].pf_results.first
        expect(res.for_judge(@judges[0]).computed_ranks).to eq([5,3,2,4,4])
        res = @pilot_flights[2].pf_results.first
        expect(res.for_judge(@judges[0]).computed_ranks).to eq([4,5,5,3,5])
        res = @pilot_flights[3].pf_results.first
        expect(res.for_judge(@judges[0]).computed_ranks).to eq([1,1,1,1,1])
        res = @pilot_flights[4].pf_results.first
        expect(res.for_judge(@judges[0]).computed_ranks).to eq([2,1,2,1,1])
      end
      it 'ranks per figure results for a flight' do
        res = @pilot_flights[0].pf_results.first
        expect(res.figure_ranks).to eq([1, 3, 3, 4, 3])
      end
      it 'computes how each judge ranked the pilots' do
        res = @pilot_flights[0].pf_results.first
        [3, 1, 3, 2].each_with_index do |r,i|
           expect(res.for_judge(@judges[i]).flight_rank).to eq(r)
        end
        res = @pilot_flights[1].pf_results.first
        [4, 4, 5, 4].each_with_index do |r,i|
           expect(res.for_judge(@judges[i]).flight_rank).to eq(r)
        end
        res = @pilot_flights[2].pf_results.first
        [5, 5, 4, 5].each_with_index do |r,i|
           expect(res.for_judge(@judges[i]).flight_rank).to eq(r)
        end
        res = @pilot_flights[3].pf_results.first
        [1, 2, 2, 1].each_with_index do |r,i|
           expect(res.for_judge(@judges[i]).flight_rank).to eq(r)
        end
        res = @pilot_flights[4].pf_results.first
        [2, 2, 1, 2].each_with_index do |r,i|
           expect(res.for_judge(@judges[i]).flight_rank).to eq(r)
        end
      end
    end
  end
end
