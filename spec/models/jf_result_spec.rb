describe JfResult, :type => :model do
  before(:context) do
    manny = Manny::Parse.new
    IO.foreach('spec/manny/Contest_300.txt') { |line| manny.processLine(line) }
    m2d = Manny::MannyToDB.new
    m2d.process_contest(manny, true)
    contest = Contest.first
    contest.results
    @pri_cat = Category.find_by_category_and_aircat('primary', 'P')
    @flight2 = contest.flights.where(:category_id => @pri_cat.id, :name => 'Free').first
    f_result = @flight2.compute_flight_results.first
    lr = Member.where(
      :family_name => 'Ramirez',
      :given_name => 'Laurie').first
    mf = Member.where(
      :family_name => 'Flournoy',
      :given_name => 'Martin').first
    j1 = Judge.where(:judge_id => lr.id).first
    j2 = Judge.where(:judge_id => mf.id).first
    @jf_result1 = f_result.jf_results.where(:judge_id => j1.id).first
    @jf_result2 = f_result.jf_results.where(:judge_id => j2.id).first
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
  it 'computes the number of minority zeros from each judge for a flight' do
    pilot_flight = @flight2.pilot_flights.first
    scores = pilot_flight.scores.first
    scores.values[0] = 0
    scores.save
    judge = scores.judge
    contest = Contest.first
    flight = contest.flights.where(:category_id => @pri_cat.id, :name => 'Free').first
    f_result = flight.compute_flight_results.first
    jf_result = f_result.jf_results.where(:judge_id => judge.id).first
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
    contest = Contest.first
    flight = contest.flights.where(:category_id => @pri_cat.id, :name => 'Free').first
    f_result = flight.compute_flight_results.first
    jf_result = f_result.jf_results.where(:judge_id => judge.id).first
    expect(jf_result.minority_grade_ct).to eq(1)
  end
  it 'counts the number of grades given by every judge for a flight' do
    expect(@flight2.count_figures_graded).to eq(42)
  end
  it 'counts the number of pilots graded by every judge for a flight' do
    expect(@flight2.count_pilots).to eq(6)
  end
end
