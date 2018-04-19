require 'test_helper'

class AirplaneModelTest < ActiveSupport::TestCase
  test "make and model enforced unique" do
    mnm = create(:airplane_model)
    assert(mnm.valid?)

    attrs = mnm.attributes
    attrs.delete(:id)
    mnm2 = AirplaneModel.create(attrs)
    refute(mnm2.valid?)

    assert(mnm2.errors.messages.has_key?(:make))
    assert(mnm2.errors.messages.has_key?(:model))
    mnm2.errors.full_messages.each do |m|
      assert(m.include?("has already been taken"))
    end
  end
end
