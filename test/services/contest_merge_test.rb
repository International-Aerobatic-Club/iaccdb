require 'test_helper'
require 'shared/basic_contest_data'

class ContestMergeTest < ActiveSupport::TestCase
  include BasicContestData

  def create_complete_contest(categories)
    setup_basic_contest_data(categories)
    cc = ContestComputer.new(@contest)
    cc.compute_results
    @contest
  end

  setup do
    @power_contest = create_complete_contest(Category.where(aircat: 'P'))
    @glider_contest = create_complete_contest(Category.where(aircat: 'G'))
    @ctst_merge = ContestMergeService.new(@power_contest)
  end

  test 'moves relations' do
    jcrs = @glider_contest.jc_results.pluck(:id)
    pcrs = @glider_contest.pc_results.pluck(:id)
    flts = @glider_contest.flights.pluck(:id)
    assert_operator(0, :<, jcrs.length)
    assert_operator(0, :<, pcrs.length)
    assert_operator(0, :<, flts.length)
    @ctst_merge.merge_contest(@glider_contest)
    @power_contest.reload
    @glider_contest.reload
    assert_equal(0, @glider_contest.jc_results.count)
    assert_equal(0, @glider_contest.pc_results.count)
    assert_equal(0, @glider_contest.flights.count)
    assert_equal(jcrs, jcrs & @power_contest.jc_results.pluck(:id))
    assert_equal(pcrs, pcrs & @power_contest.pc_results.pluck(:id))
    assert_equal(flts, flts & @power_contest.flights.pluck(:id))
  end
end
