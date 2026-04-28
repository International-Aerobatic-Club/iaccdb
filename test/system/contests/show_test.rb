require 'test_helper'

class ContestsShowTest < ActionDispatch::IntegrationTest
  test "contest with no results displays no results message" do
    contest = create(:contest)
    get contest_path(contest.id)
    assert_select('div#content') do |content|
      content = content.first
      assert_match("This contest has not posted any results.", content.text)
      assert_select('p.message')
    end
  end

  test "future contest says 'Scheduled'" do
    contest = create(:contest, start: Date.today)
    get contest_path(contest.id)
    assert_select('div#content') do |content|
      content = content.first
      assert_match("Scheduled in #{contest.city}", content.text)
    end
  end

  test "current contest says 'Held in'" do
    contest = create(:contest, start: Date.today - 3.days)
    get contest_path(contest.id)
    assert_select('div#content') do |content|
      content = content.first
      assert_match("Held in #{contest.city}", content.text)
    end
  end

  test "contest displays last updated timestamp" do
    contest = create(:contest)
    contest.update_column(:updated_at, Time.utc(2024, 1, 2, 3, 4, 0))

    get contest_path(contest.id)

    assert_select('p.contest_updated',
      "Last Updated: #{contest.reload.updated_at.strftime('%m/%d/%Y %H:%M %Z')}")
  end
end
