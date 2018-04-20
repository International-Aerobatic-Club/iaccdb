require 'test_helper'

class AirplaneMakeAndModelTest < ActiveSupport::TestCase
  test "new make and model on find_or_create" do
    make = 'Pitts'
    model = 'S-1T'
    reg = '627DP'
    airplane = Airplane.find_or_create_by_make_model_reg(
      make, model, reg)
    assert_equal(make, airplane.make)
    assert_equal(model, airplane.model)
    assert_equal(reg, airplane.reg)
    mnm = airplane.airplane_model
    refute_nil(mnm)
    assert_equal(make, mnm.make)
    assert_equal(model, mnm.model)
  end
end
