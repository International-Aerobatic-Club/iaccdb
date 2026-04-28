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

  test "contest marks collegiate participants" do
    contest = create(:contest, start: Date.new(2024, 6, 1))
    category = create(:category)
    flight = create(:flight, contest: contest, category_id: category.id)
    collegiate_pilot = create(:member, given_name: 'Casey', family_name: 'College')
    regular_pilot = create(:member, given_name: 'Riley', family_name: 'Regular')

    [collegiate_pilot, regular_pilot].each_with_index do |pilot, index|
      create(:pc_result, contest: contest, category: category, pilot: pilot,
        category_rank: index + 1, category_value: 1000 - index, total_possible: 1200)
      pilot_flight = create(:pilot_flight, flight: flight, pilot: pilot)
      create(:pf_result, pilot_flight: pilot_flight,
        adj_flight_rank: index + 1, adj_flight_value: 1000 - index,
        total_possible: 1200)
    end

    team = CollegiateResult.create!(name: 'UND', year: contest.year)
    team.members << collegiate_pilot

    get contest_path(contest.id)

    assert_select('span.collegiate-participant', count: 1)
    assert_select('span.collegiate-participant[title=?]',
      'Collegiate Series participant: UND')
  end
end
