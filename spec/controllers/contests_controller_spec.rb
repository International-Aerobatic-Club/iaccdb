describe ContestsController, :type => :controller do
  before :context do
    @ctc = 4
    @year = Time.now.year
    @contests = create_list :contest, @ctc, year: @year
    cl2 = create_list :contest, 3, year: @year - 1
    cl3 = create_list :contest, 5, year: @year - 2
    @years = [@year, @year - 1, @year - 2]
  end
  context 'index' do
    it 'responds with list of contests' do
      get :index, year: @year, :format => :json
      expect(response.status).to eq(200)
      expect(response.content_type).to eq "application/json"
      data = JSON.parse(response.body)
      expect(data['contests'].count).to eq @ctc
    end
    it 'responds with list of years' do
      get :index, year: @year, :format => :json
      data = JSON.parse(response.body)
      expect(data['years'].count).to eq @years.count
      expected = @years.collect do |y|
        contests_url(year: y, :format => :json)
      end
      expect(data['years']).to match_array(expected)
    end
    it 'contests have REST urls' do
      get :index, year: @year, :format => :json
      data = JSON.parse(response.body)
      expected = @contests.collect { |c| contest_url(c, :format => :json) }
      found = data['contests'].collect { |c| c['url'] }
      expect(found).to match_array(expected)
    end
  end
  context 'show' do
    before :context do
      @contest = @contests.first
      judge_pairs = create_list :judge, 3
      @pilots = create_list :member, 3
      @airplanes = create_list :airplane, 3
      @flights = create_list :flight, 3, contest: @contest
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
    end
    it 'responds with basic contest information' do
      get :show, id: @contest.id, :format => :json
      expect(response.status).to eq(200)
      expect(response.content_type).to eq "application/json"
      data = JSON.parse(response.body)
      expect(data['region']).to eq @contest.region
      expect(data['city']).to eq @contest.city
      expect(data['start']).to eq @contest.start.to_s
      expect(data['director']).to eq @contest.director
      expect(data['year']).to eq @contest.year
      expect(data['chapter']).to eq @contest.chapter
      expect(data['name']).to eq @contest.name
      expect(data['state']).to eq @contest.state
    end
    it 'contains categories flown' do
      get :show, id: @contest.id, :format => :json
      data = JSON.parse(response.body)
      e_cats = @contest.flights.collect { |f| f.category }
      e_cats = e_cats.uniq
      d_crs = data['category_results']
      expect(d_crs.length).to eq e_cats.length
      e_cat_names = e_cats.collect { |c| c.name }
      d_cats = d_crs.collect { |cr| cr['category'] }
      d_cat_names = d_cats.collect { |c| c['name'] }
      expect(d_cat_names).to match_array(e_cat_names)
    end
    it 'contains competitors in category' do
      get :show, id: @contest.id, :format => :json
      data = JSON.parse(response.body)
      d_crs = data['category_results']
      d_cr = d_crs.first['category']
      d_prs = d_cr['pilot_results']
      expect(d_prs.length).to eq @pilots.length
      d_pilots = d_prs.collect { |pr| pr['pilot'] }
      d_pilot = d_pilots.first
      expect(d_pilot).to_not be nil
      expect(d_pilot['iac_id']).to_not be nil
      expect(d_pilot['given_name']).to_not be nil
      expect(d_pilot['family_name']).to_not be nil
      expect(d_pilot['chapter']).to_not be nil
      d_pilot_iac_ids = d_pilots.collect { |p| p['iac_id'] }
      e_pilot_iac_ids = @pilots.collect { |p| p.iac_id }
      expect(d_pilot_iac_ids).to match_array(e_pilot_iac_ids)
    end
    it 'contains competitor airplanes in category' do
      get :show, id: @contest.id, :format => :json
      data = JSON.parse(response.body)
      d_crs = data['category_results']
      d_cr = d_crs.first['category']
      d_prs = d_cr['pilot_results']
      d_pr = d_prs.first
      d_airplane = d_pr['airplane']
      expect(d_airplane).to_not be nil
      expect(d_airplane['make']).to_not be nil
      expect(d_airplane['model']).to_not be nil
      expect(d_airplane['reg']).to_not be nil
      airplane_regs = @airplanes.collect { |a| a.reg }
      expect(airplane_regs).to include(d_airplane['reg'])
    end
    it 'contains competitor performance summaries in category' do
      get :show, id: @contest.id, :format => :json
      data = JSON.parse(response.body)
      d_crs = data['category_results']
      d_cr = d_crs.first['category']
      d_prs = d_cr['pilot_results']
      d_pr = d_prs.first
      d_result = d_pr['result']
      expect(d_result).to_not be nil
      expect(d_result['category_rank']).to_not be nil
      expect(d_result['category_value']).to_not be nil
      expect(d_result['total_possible']).to_not be nil
      expect(d_result['star_qualifying']).to_not be nil
      expect(d_result['hors_concours']).to_not be nil
    end
    it 'contains judge performance summaries in category' do
      get :show, id: @contest.id, :format => :json
      data = JSON.parse(response.body)
      d_crs = data['category_results']
      d_cr = d_crs.first['category']
      d_jrs = d_cr['judge_results']
      expect(d_jrs).to_not be nil
      expect(d_jrs.count).to eq 3
      d_jr = d_jrs.first
      j_result = d_jr['result']
      expect(j_result).to_not be nil
      expect(j_result['gamma']).to_not be nil
      expect(j_result['rho']).to_not be nil
      expect(j_result['flight_count']).to_not be nil
      expect(j_result['minority_zero_ct']).to_not be nil
      expect(j_result['minority_grade_ct']).to_not be nil
    end
    it 'contains flight detail links in category' do
      get :show, id: @contest.id, :format => :json
      data = JSON.parse(response.body)
      d_crs = data['category_results']
      d_cr = d_crs.first['category']
      d_fdls = d_cr['flights']
      expect(d_fdls).to_not be nil
      expect(d_fdls.count).to eq 3
      d_f = d_fdls.first
      expect(d_f['url']).to_not be nil
      expect(d_f['url']).to match /^http/
      expect(d_f['url']).to match /\.json$/
    end
  end
end
