require 'test_helper'

class PcResult::ComputationTest < ActiveSupport::TestCase
  setup do
    @contest = create(:nationals)
    @adams = create(:tom_adams)
    @denton = create(:bill_denton)
    judge_klein = create(:judge_klein)
    @judge_jim = create(:judge_jim)
    judge_lynne = create(:judge_lynne)
    known_flight = create(:nationals_imdt_known,
      :contest => @contest)
    @imdt_cat = known_flight.category
    @adams_flight = create(:adams_known,
      :flight => known_flight, :pilot => @adams)
    create(:adams_known_klein, 
      :pilot_flight => @adams_flight,
      :judge => judge_klein)
    create(:adams_known_jim, 
      :pilot_flight => @adams_flight,
      :judge => @judge_jim)
    create(:adams_known_lynne, 
      :pilot_flight => @adams_flight,
      :judge => judge_lynne)
    denton_flight = create(:denton_known,
      :flight => known_flight, :pilot => @denton)
    create(:denton_known_klein, 
      :pilot_flight => denton_flight,
      :judge => judge_klein)
    create(:denton_known_jim, 
      :pilot_flight => denton_flight,
      :judge => @judge_jim)
    create(:denton_known_lynne, 
      :pilot_flight => denton_flight,
      :judge => judge_lynne)
    free_flight = create(:nationals_imdt_free,
      :contest => @contest, :category => @imdt_cat)
    @adams_flight = create(:adams_free,
      :flight => free_flight, :pilot => @adams)
    create(:adams_free_klein, 
      :pilot_flight => @adams_flight,
      :judge => judge_klein)
    create(:adams_free_jim, 
      :pilot_flight => @adams_flight,
      :judge => @judge_jim)
    create(:adams_free_lynne, 
      :pilot_flight => @adams_flight,
      :judge => judge_lynne)
    denton_flight = create(:denton_free,
      :flight => free_flight, :pilot => @denton)
    create(:denton_free_klein, 
      :pilot_flight => denton_flight,
      :judge => judge_klein)
    create(:denton_free_jim, 
      :pilot_flight => denton_flight,
      :judge => @judge_jim)
    create(:denton_free_lynne, 
      :pilot_flight => denton_flight,
      :judge => judge_lynne)
    computer = ContestComputer.new(@contest)
    computer.compute_results
    @pc_results = PcResult.where(contest: @contest, category: @imdt_cat)
  end

  test 'finds two pilots in category results' do
    refute_nil(@pc_results)
    assert_equal(2, @pc_results.size)
  end

  test 'computes category total for pilot' do
    refute_nil(@pc_results)
    pc_result = @pc_results.where(:pilot_id => @adams).first
    refute_nil(pc_result)
    assert_equal(3474.83, pc_result.category_value.round(2))
    pc_result = @pc_results.where(:pilot_id => @denton).first
    refute_nil(pc_result)
    assert_equal(3459.33, pc_result.category_value.round(2))
  end

  test 'computes category rank for pilot' do
    refute_nil(@pc_results)
    pc_result = @pc_results.where(:pilot_id => @adams).first
    refute_nil(pc_result)
    assert_equal(1, pc_result.category_rank)
    pc_result = @pc_results.where(:pilot_id => @denton).first
    refute_nil(pc_result)
    assert_equal(2, pc_result.category_rank)
  end
end
