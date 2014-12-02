module Manny
  describe MannyToDB do
    before(:each) do 
      manny = Manny::Parse.new
      IO.foreach('spec/manny/Contest_36.txt') { |line| manny.processLine(line) }
      m2d = Manny::MannyToDB.new
      @contest = m2d.process_contest(manny, true)
    end
    it 'Parses' do
      @contest.should_not be nil
      @contest.start.year.should == 2005
      @contest.name.should == '2005 Gulf Coast Regional'
    end
    describe 'flights' do
      it 'computes' do
        @contest.compute_flights
      end
      describe 'contest' do
        it 'computes' do
          @contest.compute_contest_rollups
        end
      end
    end
  end
end
