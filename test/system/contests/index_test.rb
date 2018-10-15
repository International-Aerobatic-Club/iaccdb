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
    "//li//a[@href='#{contest_path(contest)}']"
  end

  def contest_item_link(contest)
    page.find(:xpath, contest_item_link_selector(contest))
  end

  def future_contest_item(item_link)
    item_link.has_xpath?('ancestor::ul[contains(@class, "future-contests")]')
  end

  test 'future contests separated into future' do
    visit contests_path
    within('div#content') do
      assert(page.has_xpath?('//h3[contains(text(),"Future contests")]'))
      @contests.each do |contest|
        item_link = contest_item_link(contest)
        assert(item_link)
        if contest.start <= @refdate
          # contests started or completed
          refute(future_contest_item(item_link))
        else
          # future contests
          assert(future_contest_item(item_link))
        end
      end
    end
  end

  test 'contests shown for current year' do
    future_season_contest = create :contest, year: @refdate.year + 1
    visit contests_path
    refute(page.has_xpath?(contest_item_link_selector(future_season_contest)))
    assert(contest_item_link(@contests.first))
  end

  test 'post contests show post date when posted' do
    contest_with_flight = create(:contest, start: @refdate - 1.week)
    flight = create :flight, contest: contest_with_flight
    visit contests_path
    item_link = contest_item_link(contest_with_flight)
    refute(future_contest_item(item_link))
    assert(item_link.has_xpath?(
      "following-sibling::text()[contains(., 'computed #{flight.created_at}')]"
    ))
  end

  test 'post contests show not yet posted' do
    contest = create(:contest, start: @refdate - 1.week)
    visit contests_path
    item_link = contest_item_link(contest)
    refute(future_contest_item(item_link))
    assert(item_link.has_xpath?(
      'following-sibling::*[contains(@class, "missing-results")]'
    ))
  end

  test 'future contests do not show not posted' do
    contest = create(:contest, start: @refdate + 1.week)
    visit contests_path
    item_link = contest_item_link(contest)
    assert(future_contest_item(item_link))
    refute(item_link.has_xpath?(
      'following-sibling::*[contains(@class, "missing-results")]'
    ))
    refute(item_link.has_xpath?(
      'following-sibling::text()[contains(., "computed")]'
    ))
  end
end
