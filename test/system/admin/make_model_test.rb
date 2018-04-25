require 'test_helper'

class ContestsIndexTest < ApplicationSystemTestCase
  setup do
    @make_models = create_list(:make_model, 12)
    @make_models.each do |mm|
      create_list(:make_model, Random.rand(1..4), make: mm.make)
    end
  end

  test "displays list of makes" do
    basic_auth_visit(admin_make_models_path, :curator)
    assert_equal(200, page.status_code)
    within('div#content') do
      assert_xpath('.//h1[contains(text(),"Makes and Models")]')
      @make_models.each do |mm|
        assert_xpath(".//li[contains(text(), \"#{mm.make}\")]")
      end
    end
  end
end
