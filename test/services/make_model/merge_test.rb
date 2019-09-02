require 'test_helper'

class MakeModel::MergeTest < ActiveSupport::TestCase
  setup do
    create_list(:airplane, Random.rand(7) + 4)
    MakeModel.all.each do |mm|
      create_list(:airplane, Random.rand(7) + 2, make_model: mm)
    end
  end

  test 'make_models have multiple airplanes' do
    MakeModel.all.each do |mm|
      assert_operator(1, :<, mm.airplanes.count)
    end
  end
end
