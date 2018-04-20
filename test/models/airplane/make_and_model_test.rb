require 'test_helper'

class AirplaneMakeAndModelTest < ActiveSupport::TestCase
  setup do
    @make = 'Pitts'
    @model = 'S-1T'
    @reg = '627DP'
  end

  test "new make and model on find_or_create" do
    airplane = Airplane.find_or_create_by_make_model_reg(
      @make, @model, @reg)
    assert_equal(@make, airplane.make)
    assert_equal(@model, airplane.model)
    assert_equal(@reg, airplane.reg)
    mnm = airplane.make_model
    refute_nil(mnm)
    assert_equal(@make, mnm.make)
    assert_equal(@model, mnm.model)
  end

  test "existing make and model on find_or_create" do
    mnm = MakeModel.create(make: @make, model: @model)
    airplane = Airplane.find_or_create_by_make_model_reg(
      @make, @model, @reg)
    assert_equal(@make, airplane.make)
    assert_equal(@model, airplane.model)
    assert_equal(@reg, airplane.reg)
    assert_equal(mnm.id, airplane.make_model_id)
  end

  test "make and model change" do
    airplane = Airplane.find_or_create_by_make_model_reg(
      @make, @model, @reg)
    new_model = 'S-1E'
    airplane.model = new_model
    assert(airplane.save)
    mnm = MakeModel.where(make: @make, model: new_model).first
    refute_nil(mnm)
    assert_equal(mnm.id, airplane.make_model_id)
  end
end
