require 'test_helper'

class MakeModel::MergeTest < ActiveSupport::TestCase
  setup do
    create_list(:airplane, Random.rand(7) + 4)
    MakeModel.all.each do |mm|
      create_list(:airplane, Random.rand(7) + 2, make_model: mm)
    end
    mms = MakeModel.limit(2).all
    @svc = MakeModelService.new(mms[1], mms[0])
  end

  test 'make_models have multiple airplanes' do
    MakeModel.all.each do |mm|
      assert_operator(1, :<, mm.airplanes.count)
    end
  end

  test 'merge service initialization' do
    mms = MakeModel.limit(2).all
    assert_equal(2, mms.count)
    target = mms[1];
    source = mms[0];
    svc = MakeModelService.new(target, source)
    assert_equal(target.id, svc.target.id)
    assert_equal(source.id, svc.source.id)
  end

  test 'merge service airplanes lists' do
    target_airplanes = @svc.target.airplanes.to_a
    source_airplanes = @svc.source.airplanes.to_a
    assert_equal(target_airplanes.collect(&:id).sort,
      @svc.target_airplanes.collect(&:id).sort)
    assert_equal(source_airplanes.collect(&:id).sort,
      @svc.source_airplanes.collect(&:id).sort)
  end
end
