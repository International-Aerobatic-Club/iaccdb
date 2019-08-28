require 'test_helper'

class ContestsIndexTest < ActionDispatch::IntegrationTest
  setup do
    Timecop.freeze
    @refdate = Date.today
    @contests = (-8 .. 8).map do |wct|
      date = @refdate + wct.weeks
      create(:contest, start: date) if date.year == @refdate.year
    end.compact
  end

  teardown do
    Timecop.return
  end

  def contest_item_link_selector(contest)
    "li//a[@href='#{contest_path(contest)}']"
  end

  def contest_item_link(contest)
    link = nil
    assert_select(contest_item_link_selector(contest)) do |contest|
      link = contest.first
    end
    assert(link)
    link
  end

  def future_contest_item(item_link)
    item_link.xpath('ancestor::ul[contains(@class, "future-contests")]')
  end

  test 'future contests separated into future' do
    get contests_path
    assert_select('div#content') do |content|
      content = content.first
      assert(content.xpath('//h3[contains(text(),"Future contests")]'))
      @contests.each do |contest|
        item_link = contest_item_link(contest)
        if contest.start <= @refdate
          # contests started or completed
          assert_empty(future_contest_item(item_link))
        else
          # future contests
          assert(future_contest_item(item_link))
        end
      end
    end
  end

  test 'contests shown for current year' do
    future_season_contest = create :contest, year: @refdate.year + 1
    get contests_path
    assert_select('div#content') do |content|
      content = content.first
      assert_empty(content.xpath(
        contest_item_link_selector(future_season_contest)))
    end
    assert(contest_item_link(@contests.first))
  end

  test 'post contests show post date when posted' do
    contest_with_flight = create(:contest, start: @refdate - 1.week)
    flight = create :flight, contest: contest_with_flight
    get contests_path
    item_link = contest_item_link(contest_with_flight)
    assert_empty(future_contest_item(item_link))
    refute_empty(item_link.xpath(
      "following-sibling::text()[contains(., 'computed #{flight.created_at}')]"
    ))
  end

  test 'post contests show not yet posted' do
    contest = create(:contest, start: @refdate - 1.week)
    get contests_path
    item_link = contest_item_link(contest)
    assert_empty(future_contest_item(item_link))
    refute_empty(item_link.xpath(
      'following-sibling::*[contains(@class, "missing-results")]'
    ))
  end

  test 'future contests do not show not posted' do
    contest = create(:contest, start: @refdate + 1.week)
    get contests_path
    item_link = contest_item_link(contest)
    assert(future_contest_item(item_link))
    assert_empty(item_link.xpath(
      'following-sibling::*[contains(@class, "missing-results")]'
    ))
    assert_empty(item_link.xpath(
      'following-sibling::text()[contains(., "computed")]'
    ))
  end
end
