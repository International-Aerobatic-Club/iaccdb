describe ContestsController, :type => :controller do
  before :context do
    @ctc = 4
    @year = Time.now.year
    @contests = create_list :contest, @ctc, year: @year
    create_list :contest, 3, year: @year - 1
    create_list :contest, 5, year: @year - 2
  end
  context 'index' do
    it 'responds with list of contests' do
      get :index, year: @year, :format => :json
      expect(response.status).to eq(200)
      expect(response.content_type).to eq "application/json"
      @data = JSON.parse(response.body)
      expect(@data['contests'].count).to eq @ctc
    end
    it 'responds with list of years' do
      get :index, year: @year, :format => :json
      @data = JSON.parse(response.body)
      expect(@data['years'].count).to eq 3
      expect(@data['years']).to contain_exactly(@year, @year-1, @year-2)
    end
    it 'contests have REST urls' do
      get :index, year: @year, :format => :json
      @data = JSON.parse(response.body)
      expected = @contests.collect { |c| contest_url(c, :format => :json) }
      found = @data['contests'].collect { |c| c['url'] }
      expect(found).to match_array(expected)
    end
  end
end
