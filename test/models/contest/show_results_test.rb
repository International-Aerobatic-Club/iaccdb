require 'test_helper'

class Contest::ShowResultsTest < ActiveSupport::TestCase
  setup do
    flight = create(:flight)
    jf_result = create(:jf_result, flight: flight)
    pilot_flight = create(:pilot_flight, flight: flight)
    @contest = flight.contest
    @contest.extend(Contest::ShowResults)
  end

  test 'extends contest with organizers method' do
    orgs = @contest.organizers
    refute(orgs.empty?)
    assert_match(@contest.director, orgs)
    assert_match(@contest.chapter.to_s, orgs)
  end

  test 'category results resilient to missing pilot_flight' do
    category = create(:category)
    flight = create(:flight, category_id: category.id, contest: @contest)
    jf_result = create(:jf_result, flight: flight)
    pc_result = create(:pc_result,
      contest: @contest,
      pilot: create(:member),
      category: category
    )
    results = @contest.category_results
    cat_result = results.first
    assert(cat_result.has_key?(:pilot_results))
    pr = cat_result[:pilot_results].first
    assert(pr.has_key?(:airplane))
    assert_nil(pr[:airplane])
  end
end
