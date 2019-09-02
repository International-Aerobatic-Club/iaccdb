
require 'test_helper'
require 'shared/make_models_data'

class Admin::MakeModelIndexTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  setup do
    @models = setup_make_models_with_airplanes
  end

  test 'unauthorized cannot view index' do
    get admin_make_models_path
    assert_response :unauthorized
  end

  test 'authorized can view index' do
    get admin_make_models_path, headers: http_auth_login(:curator)
    assert_response :success
    assert_select("form[action=\"#{admin_make_models_merge_preview_path}\"]")
    assert_select('form table tbody') do |tbody|
      tbody = tbody.first
      @models.each do |m|
        input = tbody.xpath(
          "./tr/td/input[@type=\"checkbox\" and @name=\"selected[#{m.id}]\"]"
        )
        assert_equal(1, input.length, "Have checkbox for make_model #{m.id}")
        assert_select('tr td', m.make)
        assert_select('tr td', m.model)
        assert_select("tr td a[href=\"#{edit_admin_make_model_path(m)}\"]")
        assert_select('tr td input[@type="submit"]')
        input = tbody.xpath(
          "./tr/td/input[@type=\"submit\" and @name=\"#{m.id}\"]"
        )
        assert_equal(1, input.length, "Submit named with make_model #{m.id}")
      end
    end
  end
end
