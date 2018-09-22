require 'test_helper'

class ContestsController::IndexTest < ActionController::TestCase
  setup do
    @ctc = 4
    @year = Time.now.year
    @contests = create_list :contest, @ctc, year: @year
    cl2 = create_list :contest, 3, year: @year - 1
    cl3 = create_list :contest, 5, year: @year - 2
    @years = [@year, @year - 1, @year - 2]
  end

  test 'responds with list of contests' do
    get :index, params: { year: @year }, :format => :json
    assert_response :success
    assert_equal('application/json', response.content_type)
    data = JSON.parse(response.body)
    assert(data['contests'])
    assert_equal(@ctc, data['contests'].count)
  end

  test 'responds with list of years' do
    get :index, params: { year: @year }, :format => :json
    data = JSON.parse(response.body)
    assert(data['years'])
    assert_equal(@years.count, data['years'].count)
    expected = @years.collect do |y|
      contests_url(year: y, :format => :json)
    end
    assert_equal_contents(expected, data['years'])
  end

  test 'contests have REST urls' do
    get :index, params: { year: @year }, :format => :json
    data = JSON.parse(response.body)
    assert(data['contests'])
    expected = @contests.collect { |c| contest_url(c, :format => :json) }
    found = data['contests'].collect { |c| c['url'] }
    assert_equal_contents(expected, found)
  end
end
