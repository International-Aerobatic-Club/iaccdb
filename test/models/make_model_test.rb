require 'test_helper'

class MakeModelTest < ActiveSupport::TestCase
  setup do
    @make_model = create(:make_model)
    @mm_attrs = @make_model.attributes
    @mm_attrs.delete('id')
  end

  test "setup" do
    assert(@make_model.valid?)
    refute_nil(@mm_attrs['make'])
    refute_nil(@mm_attrs['model'])
    refute(@mm_attrs.has_key?('id'))
  end

  test "make and model enforced unique" do
    mm2 = MakeModel.create(@mm_attrs)
    refute(mm2.valid?)

    assert(mm2.errors.messages.has_key?(:model))
    mm2.errors.full_messages.each do |m|
      assert(m.include?("has already been taken"))
    end
  end

  test "existing make new model" do
    new_model = 'new_model'
    mm2 = MakeModel.create(@mm_attrs.merge({model: new_model}))
    assert(mm2.valid?)
    assert_equal(new_model, mm2.model)
    assert_equal(@make_model.make, mm2.make)
  end

  test "existing model new make" do
    new_make = 'new_make'
    mm2 = MakeModel.create(@mm_attrs.merge({make: new_make}))
    assert(mm2.valid?)
    assert_equal(new_make, mm2.make)
    assert_equal(@make_model.model, mm2.model)
  end

  test "nullifies airplane references on destroy" do
    airplane = create(:airplane)
    @make_model = airplane.make_model
    @make_model.destroy
    assert_nil(airplane.reload.make_model_id)
  end
end
