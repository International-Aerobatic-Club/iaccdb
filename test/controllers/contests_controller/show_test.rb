require 'test_helper'

class ContestsController::ShowTest < ActionController::TestCase
  setup do
    @contest = create :contest
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

  test 'responds with basic contest information' do
    get :show, params: { id: @contest.id }, :format => :json
    assert_response :success
    assert_equal("application/json", response.content_type)
    data = JSON.parse(response.body)
    assert_equal(@contest.region, data['region'])
    assert_equal(@contest.city, data['city'])
    assert_equal(@contest.start.to_s, data['start'])
    assert_equal(@contest.director, data['director'])
    assert_equal(@contest.year, data['year'])
    assert_equal(@contest.chapter, data['chapter'])
    assert_equal(@contest.name, data['name'])
    assert_equal(@contest.state, data['state'])
  end

  test 'contains categories flown' do
    get :show, params: { id: @contest.id }, :format => :json
    data = JSON.parse(response.body)
    e_cats = @contest.flights.collect { |f| f.category }
    e_cats = e_cats.uniq
    d_cats = data['category_results']
    assert_equal(e_cats.length, d_cats.length)
    e_cat_names = e_cats.collect { |c| c.name }
    d_cat_names = d_cats.collect { |c| c['name'] }
    assert_equal_contents(e_cat_names, d_cat_names)
  end

  test 'contains competitors in category' do
    get :show, params: { id: @contest.id }, :format => :json
    data = JSON.parse(response.body)
    d_cats = data['category_results']
    d_cr = d_cats.first
    d_prs = d_cr['pilot_results']
    assert_equal(@pilots.length, d_prs.length)
    d_pilots = d_prs.collect { |pr| pr['pilot'] }
    d_pilot = d_pilots.first
    assert(d_pilot)
    assert(d_pilot.has_key?('iac_id'))
    assert(d_pilot.has_key?('given_name'))
    assert(d_pilot.has_key?('family_name'))
    assert(d_pilot.has_key?('chapter'))
    d_pilot_iac_ids = d_pilots.collect { |p| p['iac_id'] }
    e_pilot_iac_ids = @pilots.collect { |p| p.iac_id }
    assert_equal_contents(e_pilot_iac_ids, d_pilot_iac_ids)
  end

  test 'contains competitor airplanes in category' do
    get :show, params: { id: @contest.id }, :format => :json
    data = JSON.parse(response.body)
    d_crs = data['category_results']
    d_cr = d_crs.first
    d_prs = d_cr['pilot_results']
    d_pr = d_prs.first
    d_airplane = d_pr['airplane']
    assert(d_airplane)
    assert(d_airplane.has_key?('make'))
    assert(d_airplane.has_key?('model'))
    assert(d_airplane.has_key?('reg'))
    airplane_regs = @airplanes.collect { |a| a.reg }
    assert(airplane_regs.include?(d_airplane['reg']))
  end

  test 'contains competitor performance summaries in category' do
    get :show, params: { id: @contest.id }, :format => :json
    data = JSON.parse(response.body)
    d_crs = data['category_results']
    d_cr = d_crs.first
    d_prs = d_cr['pilot_results']
    d_pr = d_prs.first
    d_result = d_pr['result']
    assert(d_result)
    assert(d_result.has_key?('category_rank'))
    assert(d_result.has_key?('category_value'))
    assert(d_result.has_key?('total_possible'))
    assert(d_result.has_key?('star_qualifying'))
    assert(d_result.has_key?('hors_concours'))
  end

  test 'contains judge performance summaries in category' do
    get :show, params: { id: @contest.id }, :format => :json
    data = JSON.parse(response.body)
    d_crs = data['category_results']
    d_cr = d_crs.first
    d_jrs = d_cr['judge_results']
    assert(d_jrs)
    assert_equal(3, d_jrs.count)
    d_jr = d_jrs.first
    j_result = d_jr['result']
    assert(j_result)
    assert(j_result.has_key?('gamma'))
    assert(j_result.has_key?('rho'))
    assert(j_result.has_key?('flight_count'))
    assert(j_result.has_key?('minority_zero_ct'))
    assert(j_result.has_key?('minority_grade_ct'))
  end

  test 'contains flight detail links in category' do
    get :show, params: { id: @contest.id }, :format => :json
    data = JSON.parse(response.body)
    d_crs = data['category_results']
    d_cr = d_crs.first
    d_fdls = d_cr['flights']
    assert(d_fdls)
    assert_equal(3, d_fdls.count)
    d_f = d_fdls.first
    assert(d_f.has_key?('url'))
    assert_match(/^http/, d_f['url'])
    assert_match(/\.json$/, d_f['url'])
  end
end
