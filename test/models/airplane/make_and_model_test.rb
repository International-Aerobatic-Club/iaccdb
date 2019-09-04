require 'test_helper'

class AirplaneMakeAndModelTest < ActiveSupport::TestCase
  setup do
    @make = 'Pitts'
    @model = 'S-1T'
    @reg = '627DP'
  end

  test "new airplane, make and model on find_or_create" do
    # The delete_all invocations are likely unnecessary, but ensure a valid test
    Airplane.delete_all
    MakeModel.delete_all
    airplane = Airplane.find_or_create_by_make_model_reg(
      @make, @model, @reg)
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
    assert_equal(@reg, airplane.reg)
    assert_equal(mnm.id, airplane.make_model_id)
  end

  test "existing airplane on find_or_create" do
    existing = create(:airplane)
    mnm = existing.make_model
    airplane = Airplane.find_or_create_by_make_model_reg(
      mnm.make, mnm.model, existing.reg)
    assert_equal(existing.id, airplane.id)
  end

  test 'splits make model' do
    mm = Airplane.split_make_model('Pitts S-1S')
    assert_equal('Pitts', mm[0])
    assert_equal('S-1S', mm[1])
    mm = Airplane.split_make_model('Decathlon')
    assert_nil(mm[0])
    assert_equal('Decathlon', mm[1])
    mm = Airplane.split_make_model('Extra 330 LX')
    assert_equal('Extra', mm[0])
    assert_equal('330 LX', mm[1])
  end
end
