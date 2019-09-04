require 'test_helper'

class MakeModel::FindTest < ActiveSupport::TestCase
  setup do
    make_models = create_list(:make_model, 6 + Random.rand(12))
    @make_model = make_models[Random.rand(make_models.length)]
  end

  test 'finds existing' do
    mm = MakeModel.find_or_create_make_model(
      @make_model.make, @make_model.model)
    assert_equal(@make_model.id, mm.id)
  end

  test 'creates missing' do
    make = @make_model.make
    model = @make_model.model
    @make_model.destroy
    assert(@make_model.destroyed?)
    mm = MakeModel.find_or_create_make_model(make, model)
    refute_nil(mm)
    assert_equal(make, mm.make)
    assert_equal(model, mm.model)
  end
end
