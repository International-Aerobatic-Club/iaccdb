describe JfResult, :type => :model do
  def reparse_contest(m2d, manny)
    m2d.process_contest(manny, true)
    @contest = Contest.first
    @pri_cat = Category.find_by_category_and_aircat('primary', 'P')
    @flight2 = @contest.flights.where(:category_id => @pri_cat.id, :name => 'Free').first
  end
  context 'computed contest' do
    before(:context) do
      @manny = Manny::Parse.new
      IO.foreach('spec/manny/Contest_300.txt') { |line| @manny.processLine(line) }
      @m2d = Manny::MannyToDB.new
      reparse_contest(@m2d, @manny)
      computer = ContestComputer.new(@contest)
      computer.compute_results
      expect(Failure.all).to be_empty
      lr = Member.where(
        :family_name => 'Ramirez',
        :given_name => 'Laurie').first
      mf = Member.where(
        :family_name => 'Flournoy',
        :given_name => 'Martin').first
      j1 = Judge.where(:judge_id => lr.id).first
      j2 = Judge.where(:judge_id => mf.id).first
      @jf_result1 = JfResult.where(judge: j1, flight: @flight2).first
      @jf_result2 = JfResult.where(judge: j2, flight: @flight2).first
    end
    it 'computes the Spearman rank coefficient for each judge of a flight' do
      expect(@jf_result1.rho).to eq(54)
      expect(@jf_result2.rho).to eq(77)
    end
    it 'computes the CIVA RI formula for each judge of a flight' do
      expect(@jf_result1.ri).to eq(4.39)
      expect(@jf_result2.ri).to eq(3.74)
    end
    it 'computes the Kendal tau for each judge of a flight' do
      expect(@jf_result1.tau).to eq(47)
      expect(@jf_result2.tau).to eq(60)
    end
    it 'computes the Gamma for each judge of a flight' do
      expect(@jf_result1.gamma).to eq(47)
      expect(@jf_result2.gamma).to eq(60)
    end
    it 'computes the standard correlation coefficient for each judge of a flight' do
      expect(@jf_result1.cc).to eq(54)
      expect(@jf_result2.cc).to eq(77)
    end
    it 'counts the number of grades given by every judge for a flight' do
      expect(@flight2.count_figures_graded).to eq(42)
    end
    it 'counts the number of pilots graded by every judge for a flight' do
      expect(@flight2.count_pilots).to eq(6)
    end
    context 'clean contest' do
      before :each do
        reparse_contest(@m2d, @manny)
      end
      it 'computes the number of minority zeros from each judge for a flight' do
        pilot_flight = @flight2.pilot_flights.first
        scores = pilot_flight.scores.first
        scores.values[0] = 0
        scores.save
        judge = scores.judge
        computer = FlightComputer.new(@flight2)
        computer.flight_results(false)
        jf_result = JfResult.where(flight: @flight2, judge: judge).first
        expect(jf_result.minority_zero_ct).to eq(1)
      end
      it 'computes the number of minority grades from each judge for a flight' do
        pilot_flight = @flight2.pilot_flights.first
        judge = nil
        pilot_flight.scores.each_with_index do |scores, i|
          if i%2 == 0
            scores.values[1] = 0 
            scores.save
          else
            judge = scores.judge
          end
        end
        expect(judge).not_to be nil
        computer = FlightComputer.new(@flight2)
        computer.flight_results(false)
        jf_result = JfResult.where(flight: @flight2, judge: judge).first
        expect(jf_result.minority_grade_ct).to eq(1)
      end
    end
  end
end
