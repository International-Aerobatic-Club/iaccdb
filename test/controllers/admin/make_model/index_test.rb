
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

  test 'index view shows curated make_models' do
    curated_index = Random.rand(@models.length)
    uncurated_model = @models[curated_index == 0 ? 1 : curated_index - 1]
    curated_model = @models[curated_index]
    curated_model.curated = true
    curated_model.save!
    get admin_make_models_path, headers: http_auth_login(:curator)
    assert_response :success
    assert_select("form[action=\"#{admin_make_models_merge_preview_path}\"]")
    assert_select('form table tbody') do |tbody|
      tbody = tbody.first
      input = tbody.xpath(
        "./tr/td/input[@type=\"checkbox\" and @name=\"selected[#{curated_model.id}]\"]"
      )
      assert_equal(1, input.length, "Have checkbox for make_model #{curated_model.id}")
      td = input.first.parent
      assert_match(/👍/, td.text)
      input = tbody.xpath(
        "./tr/td/input[@type=\"checkbox\" and @name=\"selected[#{uncurated_model.id}]\"]"
      )
      assert_equal(1, input.length, "Have checkbox for make_model #{uncurated_model.id}")
      td = input.first.parent
      refute_match(/👍/, td.text)
    end
  end
end
