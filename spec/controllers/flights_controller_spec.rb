describe FlightsController, type: :controller do
  require 'shared/computed_contest_context'
  include_context 'computed contest'
  it 'responds with basic flight information' do
    get :show, params: { id: @flight.id }, format: :json
    expect(response.status).to eq(200)
    expect(response.content_type).to eq "application/json"
    data = JSON.parse(response.body)
    d_fl = data['flight']
    expect(d_fl).to_not be nil
    expect(d_fl['id']).to eq @flight.id
    expect(d_fl['name']).to eq @flight.name
    expect(d_fl['sequence']).to eq @flight.sequence
  end
  it 'includes contest information' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_c = d_fl['contest']
    expect(d_c['url']).to eq contest_url(@flight.contest, format: :json)
    expect(d_c['director']).to eq @flight.contest.director
    expect(d_c['name']).to eq @flight.contest.name
    expect(d_c['year']).to eq @flight.contest.year
    expect(d_c['start']).to eq @flight.contest.start.to_s
  end
  it 'includes category information' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_cats = d_fl['categories']
    expect(d_cats).to_not be nil
    expect(d_cats.length).to eq @flight.categories.count
    d_cats.each do |d_cat|
      cat = @flight.categories.find_by(sequence: d_cat['sequence'])
      expect(cat).to_not be nil
      expect(d_cat['aircat']).to eq cat.aircat
      expect(d_cat['name']).to eq cat.name
      expect(d_cat['level']).to eq cat.category
    end
  end
  it 'includes pilot flights' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_pfs = d_fl['pilot_results']
    expect(d_pfs).to_not be nil
    expect(d_pfs.count).to eq @flight.pilot_flights.count
  end
  it 'includes pilot flight pilot information' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_pfs = d_fl['pilot_results']
    d_pf = d_pfs.first
    expect(d_pf).to_not be nil
    d_pilot = d_pf['pilot']
    expect(d_pilot).to_not be nil
    d_pf_id = d_pf['id'].to_int
    pf = @flight.pilot_flights.where(id: d_pf_id)
    expect(pf).to_not be_nil
    pf = pf.first
    pilot = pf.pilot
    expect(d_pilot['id']).to eq pilot.id
    expect(d_pilot['name']).to eq pilot.name
    expect(d_pilot['url']).to eq pilot_url(pilot, format: :json)
  end
  it 'includes pilot flight urls' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_pfs = d_fl['pilot_results']
    d_pf = d_pfs.first
    expect(d_pf).to_not be nil
    d_pf_id = d_pf['id'].to_int
    pf = @flight.pilot_flights.where(id: d_pf_id)
    expect(pf).to_not be_nil
    pf = pf.first
    expect(d_pf['url']).to eq pilot_flight_url(pf, format: :json)
  end
  it 'includes pilot flight result information' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_pfs = d_fl['pilot_results']
    d_pf = d_pfs.first
    expect(d_pf).to_not be nil
    d_pf_id = d_pf['id'].to_int
    pf = @flight.pilot_flights.where(id: d_pf_id)
    pf = pf.first
    expect(pf).to_not be_nil
    pfr = pf.pf_results.first
    expect(pfr).to_not be nil
    expect(d_pf['penalty_total']).to eq pf.penalty_total
    expect(d_pf['score_before_penalties']).to eq pfr.flight_value.to_s
    expect(d_pf['score']).to eq pfr.adj_flight_value.to_s
    expect(d_pf['rank_before_penalties']).to eq pfr.flight_rank
    expect(d_pf['rank']).to eq pfr.adj_flight_rank
    expect(d_pf['total_possible']).to eq pfr.total_possible
  end
  it 'includes airplane information in pilot flight result' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_pfs = d_fl['pilot_results']
    d_pf = d_pfs.first
    expect(d_pf).to_not be nil
    d_pf_id = d_pf['id'].to_int
    pf = @flight.pilot_flights.where(id: d_pf_id)
    pf = pf.first
    expect(pf).to_not be_nil
    pfr = pf.pf_results.first
    expect(pfr).to_not be nil
    airplane = pf.airplane
    d_a = d_pf['airplane']
    expect(d_a).to_not be nil
    expect(d_a['make']).to eq airplane.make_model.make
    expect(d_a['model']).to eq airplane.make_model.model
    expect(d_a['reg']).to eq airplane.reg
    expect(d_a['id']).to eq airplane.id
  end
  it 'includes judge results' do
    get :show, params: { id: @flight.id }, format: :json
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_jfs = d_fl['line_judges']
    expect(d_jfs).to_not be nil
    d_jf = d_jfs.first
    expect(d_jf).to_not be nil
    d_jf_id = d_jf['id'].to_int
    jf_result = JfResult.find(d_jf_id)
    expect(jf_result).to_not be nil
    judge_pair = jf_result.judge
    expect(judge_pair).to_not be nil
    d_j = d_jf['judge']
    expect(d_j).to_not be nil
    expect(d_j['id']).to eq judge_pair.judge.id
    expect(d_j['name']).to eq judge_pair.judge.name
    expect(d_j['url']).to eq judge_url(judge_pair.judge, format: :json)
    d_a = d_jf['assistant']
    expect(d_a).to_not be nil
    expect(d_a['id']).to eq judge_pair.assist.id
    expect(d_a['name']).to eq judge_pair.assist.name
    expect(d_jf['rho']).to eq jf_result.rho
    expect(d_jf['gamma']).to eq jf_result.gamma
    expect(d_jf['tau']).to eq jf_result.tau
    expect(d_jf['cc']).to eq jf_result.cc
    expect(d_jf['ri']).to eq jf_result.ri.to_s
    expect(d_jf['pilot_count']).to eq jf_result.pilot_count
    expect(d_jf['pair_count']).to eq jf_result.pair_count
    expect(d_jf['flight_count']).to eq jf_result.flight_count
    expect(d_jf['average_flight_size']).to eq jf_result.avgFlightSize
    expect(d_jf['figure_count']).to eq jf_result.figure_count
    expect(d_jf['average_k']).to eq jf_result.avgK
    expect(d_jf['minority_zeros']).to eq jf_result.minority_zero_ct
    expect(d_jf['minority_grades']).to eq jf_result.minority_grade_ct
    expect(d_jf['url']).to eq jf_result_url(jf_result, format: :json)
  end
  it 'retrieves judge pair with nil assistant' do
    judge = @jf_result.judge
    judge.assist = nil
    judge.save!
    expect(judge.assist).to be nil
    flight = @jf_result.flight
    begin
      get :show, params: { id: flight.id }, format: :json
    rescue => e
      fail "Get flight not expected to raise #{e.message}"
    end
    expect(response.status).to eq(200)
    expect(response.content_type).to eq "application/json"
    data = JSON.parse(response.body)
    d_fl = data['flight']
    d_jfs = d_fl['line_judges']
    judge_ct = flight.jf_results.length
    expect(d_jfs.length).to eq judge_ct
    assist_ids = d_jfs.collect do |d_jf|
      assistant = d_jf['assistant']
      if assistant != nil
        assistant['id']
      else
        nil
      end
    end
    expect(assist_ids.compact.count).to eq(judge_ct - 1)
  end
end

