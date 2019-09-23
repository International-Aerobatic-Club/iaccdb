require 'test_helper'

class FurtherControllerTest < ActionDispatch::IntegrationTest
  def setup
    years = [2017, 2018]
    years.each do |year|
      Category.all.limit(2).each do |category|
        create_list(:jy_result, 12 + Random.rand(12),
          year: year, category: category)
        contest = create(:contest, start: "#{year}-09-04")
        flight = create(:flight, contest: contest, category_id: category.id)
        create_list(:pilot_flight, 12 + Random.rand(12), flight: flight)
      end
    end
  end

  test 'view participation page' do
    get further_participation_path
    assert_response :success
  end

  test 'view airplanes page' do
    get further_airplanes_path
    assert_response :success
  end
end
