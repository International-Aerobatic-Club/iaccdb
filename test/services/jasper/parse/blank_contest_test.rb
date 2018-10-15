require 'test_helper'
require_relative '../contest_data'

class BlankContestTest < ActiveSupport::TestCase
  include ContestData

  setup do
    @jasper = parse_contest_data(blank_empty_contest)
  end

  test 'string fields return a value' do
    refute_nil(@jasper.contest_name)
    refute_nil(@jasper.contest_city)
    refute_nil(@jasper.contest_state)
    refute_nil(@jasper.contest_chapter)
    refute_nil(@jasper.contest_region)
    refute_nil(@jasper.contest_director)
    refute_nil(@jasper.aircat)
  end

  test 'contest id returns nil' do
    assert_nil(@jasper.contest_id)
  end

  test 'contest date returns nil' do
    assert_nil(@jasper.contest_date)
  end

  test 'aircat returns default' do
    assert_equal('P', @jasper.aircat)
  end

  test 'string fields are blank' do
    assert_empty(@jasper.contest_name)
    assert_empty(@jasper.contest_city)
    assert_empty(@jasper.contest_state)
    assert_empty(@jasper.contest_chapter)
    assert_empty(@jasper.contest_region)
    assert_empty(@jasper.contest_director)
  end
end
