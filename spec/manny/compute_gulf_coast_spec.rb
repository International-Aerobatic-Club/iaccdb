module Manny
  describe MannyToDB do
    before(:context) do 
      manny = Manny::Parse.new
      IO.foreach('spec/manny/Contest_36.txt') { |line| manny.processLine(line) }
      m2d = Manny::MannyToDB.new
      @contest = m2d.process_contest(manny, true)
      @computer = ContestComputer.new(@contest)
    end
    it 'parses' do
      expect(@contest).not_to be nil
      expect(@contest.start.year).to eq(2005)
      expect(@contest.name).to eq('2005 Gulf Coast Regional')
    end
    describe 'flights' do
      it 'computes' do
        @computer.compute_flights
      end
    end
    describe 'contest' do
      it 'computes pilots' do
        @computer.compute_contest_pilot_rollups
      end
      it 'computes judges' do
        @computer.compute_contest_judge_rollups
      end
    end
  end
end
