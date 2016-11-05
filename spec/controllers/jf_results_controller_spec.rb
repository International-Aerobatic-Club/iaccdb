describe JfResultsController, :type => :controller do
  before :context do
    @year = Time.now.year
    @contest = create :contest, year: @year
    @ctf = 3
    @category = Category.first
    @flights = create_list :flight, @ctf, contest: @contest, category: @category
    @flight = @flights.first
    @pilots = create_list :member, 3
    @airplanes = create_list :airplane, 3
    judge_pairs = create_list :judge, 3
    @flights.each do |flight|
      @pilots.each_with_index do |p, i|
        pf = create :pilot_flight, flight: flight, pilot: p,
          airplane: @airplanes[i]
        judge_pairs.each do |j|
          s = create :score, pilot_flight: pf, judge: j
        end
      end
    end
    @judges = judge_pairs.collect { |jp| jp.judge }
    cc = ContestComputer.new(@contest)
    cc.compute_results
    @judge = judge_pairs.first
    @jf_result = JfResult.where(flight: @flight, judge: @judge).first
  end
  it 'responds with basic judge information' do
    get :show, id: @jf_result.id, :format => :json
    expect(response.status).to eq(200)
    expect(response.content_type).to eq "application/json"
    data = JSON.parse(response.body)
    d_jf = data['judge_flight_data']
    expect(d_jf).to_not be nil
    expect(d_jf['id']).to eq @jf_result.id
  end
  it 'responds with judge summary data' do
    get :show, id: @jf_result.id, :format => :json
    expect(response.status).to eq(200)
    expect(response.content_type).to eq "application/json"
    data = JSON.parse(response.body)
    d_jf = data['judge_flight_data']
    expect(d_jf['gamma']).to eq @jf_result.gamma
    expect(d_jf['rho']).to eq @jf_result.rho
    expect(d_jf['tau']).to eq @jf_result.tau
    expect(d_jf['cc']).to eq @jf_result.cc
    expect(d_jf['ri']).to eq @jf_result.ri.to_s
    expect(d_jf['pilot_count']).to eq @jf_result.pilot_count
    expect(d_jf['pair_count']).to eq @jf_result.pair_count
    expect(d_jf['flight_count']).to eq @jf_result.flight_count
    expect(d_jf['average_flight_size']).to eq @jf_result.avgFlightSize
    expect(d_jf['figure_count']).to eq @jf_result.figure_count
    expect(d_jf['average_k']).to eq @jf_result.avgK
    expect(d_jf['minority_zeros']).to eq @jf_result.minority_zero_ct
    expect(d_jf['minority_grades']).to eq @jf_result.minority_grade_ct
  end
end

