require 'test_helper'

class ContestsShowTest < ActionDispatch::IntegrationTest
  test "contest with no results" do
    contest = create(:contest)
    visit contest_path(contest.id)
    within('div#content') do
      assert(page.has_text?('This contest has not posted any results.'))
    end
  end
end
