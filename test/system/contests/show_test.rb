require 'test_helper'

class ContestsShowTest < ActionDispatch::IntegrationTest
  test "contest with no results displays no results message" do
    contest = create(:contest)
    visit contest_path(contest.id)
    within('div#content') do
      assert(page.has_text?('This contest has not posted any results.'))
      assert(page.has_css?('p.message'))
    end
  end

  test "future contest says 'Scheduled'" do
    contest = create(:contest, start: Date.today)
    visit contest_path(contest.id)
    within('div#content') do
      assert(page.has_text?("Scheduled in #{contest.city}"))
    end
  end

  test "current contest says 'Held in'" do
    contest = create(:contest, start: Date.today - 3.days)
    visit contest_path(contest.id)
    within('div#content') do
      assert(page.has_text?("Held in #{contest.city}"))
    end
  end
end
