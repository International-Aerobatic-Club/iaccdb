require 'test_helper'
require_relative '../contest_data'

class StartDateTest < ActiveSupport::TestCase
  include ContestData

  test 'parses yyyy-mm-dd date format' do
    now = Date.today
    Timecop.freeze(now) do
      jasper = parse_contest_data(blank_empty_contest({
        start: now.strftime('%Y-%m-%d')
      }))
      assert_equal(now, jasper.contest_date)
    end
  end

  test 'parses m/d/yy date format' do
    now = Date.today
    Timecop.freeze(now) do
      jasper = parse_contest_data(blank_empty_contest({
        start: now.strftime('%m/%d/%y')
      }))
      assert_equal(now, jasper.contest_date)
    end
  end


end
