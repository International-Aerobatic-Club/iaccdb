require "test_helper"

class SyntheticCategoryTest < ActiveSupport::TestCase
  def synthetic_category
    @synthetic_category ||= build :synthetic_category
  end

  def test_valid
    assert synthetic_category.valid?
  end

  def test_serialized
    assert_equal(Array, synthetic_category.regular_category_flights.class)
    assert_equal(Array, synthetic_category.synthetic_category_flights.class)
  end
end
