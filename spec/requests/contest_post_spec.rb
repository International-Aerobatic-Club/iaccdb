RSpec.describe 'Contest management API' do
  def check_contest(contest, expected_values)
    expect(contest.name).to eq expected_values[:name]
    expect(contest.start).to eq expected_values[:start]
    expect(contest.city).to eq expected_values[:city]
    expect(contest.state).to eq expected_values[:state]
    expect(contest.chapter).to eq expected_values[:chapter]
    expect(contest.director).to eq expected_values[:director]
    expect(contest.region).to eq expected_values[:region]
  end

  def check_response(response, expected_values)
    contest_hash = JSON.parse(response.body)
    expect(contest_hash['name']).to eq expected_values[:name]
    expect(contest_hash['start']).to eq expected_values[:start].to_s
    expect(contest_hash['city']).to eq expected_values[:city]
    expect(contest_hash['state']).to eq expected_values[:state]
    expect(contest_hash['chapter']).to eq expected_values[:chapter]
    expect(contest_hash['director']).to eq expected_values[:director]
    expect(contest_hash['region']).to eq expected_values[:region]
    expect(contest_hash['id']).to_not be nil
  end

  def json_headers
    json_mime_type = 'application/json'
    {
       'ACCEPT' => json_mime_type,
       'HTTP_ACCEPT' => json_mime_type,
       'CONTENT_TYPE' => json_mime_type
    }
  end

  def auth_headers
    http_auth_login('contest_admin', json_headers)
  end

  def json_body(data_hash)
    JSON.pretty_generate(data_hash)
  end

  before :context do
    @valid_contest_params = {
      name: 'Rocky Mountain Aerobatic Championship',
      start: Date.today + 60.days,
      city: 'Fort Morgan',
      state: 'CO',
      chapter: 12,
      director: 'Cherry Garcia',
      region: 'Southwest'
    }
    @invalid_contest_params = {
      start: Date.today - 760.days,
      city: 'Fort Morgan',
      director: 'Cherry Garcia',
      region: 'Southwest'
    }
  end

  context 'POST' do
    it 'can post a new contest' do
      post '/contests',
        json_body({ contest: @valid_contest_params }),
        auth_headers
      expect(response).to have_http_status(:success)
      expect(Contest.count).to eq 1
      contest = Contest.first
      expect(contest).to_not be nil
      expect(contest.id).to_not be nil
      check_contest(contest, @valid_contest_params)
      check_response(response, @valid_contest_params)
    end

    it 'cannot update through post' do
      contest = Contest.create!(@valid_contest_params)
      contest_params = @valid_contest_params.merge({
        id: contest.id
      })
      post '/contests',
        json_body({ contest: contest_params }),
        auth_headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data['id']).to_not be nil
      expect(data['id']).not_to eq contest.id
    end

    it 'cannot post without authorization' do
      post '/contests',
        json_body({ contest: @valid_contest_params }),
        json_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns bad request for invalid data' do
      post '/contests',
        json_body({ contest: @invalid_contest_params }),
        auth_headers
      expect(response).to have_http_status(:bad_request)
    end

    it 'error response contains validation information' do
      post '/contests',
        json_body({ contest: @invalid_contest_params }),
        auth_headers
      expect(response.body).to_not be_empty
      data = JSON.parse(response.body)
      expect(data).to_not be nil
      expect(data["errors"]).to_not be nil
    end
  end

  context 'PUT' do
    before :example do
      @contest = Contest.create!(@valid_contest_params)
      @new_date = @contest.start + 14.days
      @valid_update_params = @valid_contest_params.merge({
        start: @new_date,
        name: 'Ben Lowell Aerobatic Championship'
      })
    end

    it 'can update a contest' do
      put "/contests/#{@contest.id}",
        json_body({ contest: @valid_update_params }),
        auth_headers
      expect(response).to have_http_status(:success)
      check_contest(@contest.reload, @valid_update_params)
      check_response(response, @valid_update_params)
    end

    it 'cannot update a non_existing contest' do
      put "/contests/#{@contest.id + 42}",
        json_body({ contest: @valid_update_params }),
        auth_headers
      expect(response).to have_http_status(:not_found)
      check_contest(@contest.reload, @valid_contest_params)
    end

    it 'cannot change the id' do
      original_id = @contest.id
      overwrite_attempt_params = @valid_contest_params.merge({
        id: original_id + 42,
        start: @new_date,
        name: 'Ben Lowell Aerobatic Championship'
      })
      put "/contests/#{original_id}",
        json_body({ contest: overwrite_attempt_params }),
        auth_headers
      expect(response).to have_http_status(:success)
      expect(@contest.reload.id).to eq original_id
      data = JSON.parse(response.body)
      expect(data['id']).to eq original_id
      check_contest(@contest.reload, overwrite_attempt_params)
      check_response(response, overwrite_attempt_params)
    end

    it 'cannot put without authorization' do
      put "/contests/#{@contest.id}",
        json_body({ contest: @valid_update_params }),
        json_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'DELETE' do
    before :example do
      @contest = Contest.create!(@valid_contest_params)
    end

    it 'can delete a contest' do
      original_id = @contest.id
      delete "/contests/#{original_id}", nil, auth_headers
      expect(response).to have_http_status(:success)
      expect(Contest.count).to eq 0
      expect{
        Contest.find(original_id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'cannot delete a non-existing contest' do
      original_id = @contest.id
      delete "/contests/#{original_id+42}", nil, auth_headers
      expect(response).to have_http_status(:not_found)
      expect(Contest.count).to eq 1
      expect(Contest.find(original_id)).to_not be nil
    end

    it 'cannot delete without authorization' do
      delete "/contests/#{@contest.id}", nil, json_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
