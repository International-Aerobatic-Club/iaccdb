describe PilotFlightsController, :type => :controller do
  require 'shared/computed_contest_context'
  include_context 'computed contest'
  it 'responds with basic pilot flight information' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    expect(response.status).to eq(200)
    expect(response.content_type).to eq "application/json"
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    expect(d_pf).to_not be nil
    expect(d_pf['id']).to eq @pilot_flight.id
  end
  it 'responds with pilot information' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    pilot = @pilot_flight.pilot
    d_p = d_pf['pilot']
    expect(d_p).to_not be nil
    expect(d_p['id']).to eq pilot.id
    expect(d_p['name']).to eq pilot.name
    expect(d_p['iac_id']).to eq pilot.iac_id
  end
  it 'responds with pilot flight summary data' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    expect(d_pf['chapter']).to eq @pilot_flight.chapter
    expect(d_pf['hors_concours']).to eq @pilot_flight.hors_concours?
    expect(d_pf['penalty_total']).to eq @pilot_flight.penalty_total
  end
  it 'responds with the airplane flown' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    d_a = d_pf['airplane']
    expect(d_a).to_not be nil
    expect(d_a['make']).to eq @pilot_flight.airplane.make
    expect(d_a['model']).to eq @pilot_flight.airplane.model
    expect(d_a['reg']).to eq @pilot_flight.airplane.reg
  end
  it 'responds with the flight information' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    d_f = d_pf['flight']
    expect(d_f).to_not be nil
    flight = @pilot_flight.flight
    expect(d_f['url']).to eq flight_url(flight, :format => :json)
    expect(d_f['id']).to eq flight.id
    expect(d_f['name']).to eq flight.name
    expect(d_f['category']).to eq flight.category.name
  end
  it 'responds with judge flight grades for pilot' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    d_gs = d_pf['grades']
    expect(d_gs).to_not be nil
    expect(d_gs.length).to eq 3
    d_g = d_gs.first
    d_j = d_g['judge']
    expect(d_j).to_not be nil
    j_id = d_j['id'].to_int
    j_score = @pilot_flight.scores.select{|s| s.judge.judge.id == j_id}.first
    judge_pair = j_score.judge
    judge = judge_pair.judge
    expect(j_score).to_not be nil
    expect(d_j['name']).to eq judge.name
    expect(d_j['url']).to eq judge_url(judge, :format => :json)
    d_vs = d_g['values']
    expect(d_vs).to_not be nil
    expect(d_vs).to match_array(j_score.values)
    d_a = d_g['assistant']
    expect(d_a).to_not be nil
    expect(d_a['id']).to eq judge_pair.assist.id
    expect(d_a['name']).to eq judge_pair.assist.name
  end
  it 'responds with flight sequence information' do
    get :show, params: { id: @pilot_flight.id }, :format => :json
    data = JSON.parse(response.body)
    d_pf = data['pilot_flight_data']
    d_s = d_pf['sequence']
    expect(d_s).to_not be nil
    sequence = @pilot_flight.sequence
    expect(d_s['k_values']).to match_array sequence.k_values
    expect(d_s['total_k']).to eq sequence.total_k
  end
end

