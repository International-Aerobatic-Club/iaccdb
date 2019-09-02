require 'test_helper'
require 'shared/make_models_data'

class MakeModel::MergeTest < ActiveSupport::TestCase
  include MakeModelsData

  setup do
    setup_make_models_with_airplanes
    mms = MakeModel.limit(2).all
    @source = mms[0]
    @target = mms[1]
    @svc = MakeModelService.new(@target, @source)
  end

  test 'make_models have multiple airplanes' do
    MakeModel.all.each do |mm|
      assert_operator(1, :<, mm.airplanes.count)
    end
  end

  test 'merge service initialization' do
    assert_equal(@target.id, @svc.target_id)
    assert_equal(@source.id, @svc.source_id)
  end

  test 'merge' do
    airplane_ids = @source.airplanes.collect(&:id) +
      @target.airplanes.collect(&:id)
    @svc.merge
    mm_target = MakeModel.find(@svc.target_id)
    refute_nil(mm_target)
    assert_equal(airplane_ids.sort,
      mm_target.airplanes.collect(&:id).sort)
    mm_source = MakeModel.find_by(id: @svc.source_id)
    assert_nil(mm_source)
  end
end
