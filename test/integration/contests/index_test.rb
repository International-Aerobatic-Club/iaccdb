require 'test_helper'

class ContestsIndexTest < ActionDispatch::IntegrationTest
  setup do
    Timecop.freeze
    @refdate = Date.today
    @contests = (-8 .. 8).map do |wct|
      date = @refdate + wct.weeks
      create(:contest, start: date)
    end
  end

  teardown do
    Timecop.return
  end

  test "future contests separated into future" do
    visit contests_path
    within('div#content') do
      assert(page.has_xpath?("//h3[contains(text(),'Future contests')]"))
      class_test = "contains(@class, 'future-contests')"
      @contests.each do |contest|
        list_item = page.find(:xpath,
          "//li//a[@href='#{contest_path(contest.id)}']")
        if contest.start <= @refdate
          # contests started or completed
          assert(list_item.has_xpath?("ancestor::ul[not(#{class_test})]"))
          refute(list_item.has_xpath?("ancestor::ul[#{class_test}]"))
        else
          # future contests
          refute(list_item.has_xpath?("ancestor::ul[not(#{class_test})]"))
          assert(list_item.has_xpath?("ancestor::ul[#{class_test}]"))
        end
      end
    end
  end
end
