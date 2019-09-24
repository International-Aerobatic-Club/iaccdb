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

  test 'creates synthetic category' do
    last_seq = Category.maximum(:sequence)
    cur_ct = Category.count
    cat = synthetic_category.find_or_create
    refute_nil(cat)
    assert_equal(cur_ct + 1, Category.count)
    assert_equal(last_seq + 1, cat.sequence)
    assert_equal(synthetic_category.synthetic_category_description, cat.name)
    reg_cat = synthetic_category.regular_category
    assert_equal(reg_cat.category, cat.category)
    assert_equal(reg_cat.aircat, cat.aircat)
    assert(cat.synthetic)
    assert_equal(Category.pluck(:sequence).max, cat.sequence)
  end

  test 'finds existing synthetic category' do
    cat = synthetic_category.find_or_create
    cat_too = synthetic_category.find_or_create
    assert_equal(cat, cat_too)
  end
end
