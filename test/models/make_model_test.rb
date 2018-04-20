require 'test_helper'

class MakeModelTest < ActiveSupport::TestCase
  test "make and model enforced unique" do
    mnm = create(:make_model)
    assert(mnm.valid?)

    attrs = mnm.attributes
    attrs.delete(:id)
    mnm2 = MakeModel.create(attrs)
    refute(mnm2.valid?)

    assert(mnm2.errors.messages.has_key?(:make))
    assert(mnm2.errors.messages.has_key?(:model))
    mnm2.errors.full_messages.each do |m|
      assert(m.include?("has already been taken"))
    end
  end

  test "nullifies airplane references on destroy" do
    airplane = create(:airplane)
    mnm = airplane.make_model
    mnm.destroy
    assert_nil(airplane.reload.make_model_id)
  end
end
