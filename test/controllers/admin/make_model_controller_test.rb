require 'test_helper'
require 'shared/make_models_data'

class Admin::MakeModelControllerTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  setup do
    @models = setup_make_models_with_airplanes
    select = []
    4.times do
      select << @models[Random.rand(@models.length)]
    end
    @select_models = select.uniq
  end

  test 'unauthorized cannot view index' do
    get admin_make_models_path
    assert_response :unauthorized
  end

  test 'unauthorized cannot preview merge' do
    post admin_make_models_merge_preview_path
    assert_response :unauthorized
  end

  test 'unauthorized cannot show' do
    get admin_make_model_path(@models.first)
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
      end
    end
  end

  test 'authorized can preview merge' do
    post admin_make_models_merge_preview_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_select_params(@select_models)
    assert_response :success
  end

  test 'merge preview has radio selector for target' do
    post admin_make_models_merge_preview_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_select_params(@select_models)
    assert_select('ul.make-model-targets') do |ul|
      assert_equal(1, ul.length)
      ul = ul.first
      @select_models.each do |mm|
        assert_equal(1,
          ul.xpath(
            './li/input[' +
            "@type=\"radio\" and @name=\"target\" and @value=\"#{mm.id}\"" +
            ']'
          ).length,
          "Radio button input \"target\" with value, \"#{mm.id}\""
        )
        assert_equal(1,
          ul.xpath(
            "./li/input[@type=\"hidden\" and @name=\"selected[#{mm.id}]\"]"
          ).length,
          "Hidden select input with name, \"selected[#{mm.id}]\""
        )
        assert_select(ul, 'li', /#{mm.make}, #{mm.model}/)
      end
    end
  end

  test 'merge preview lists affected airplanes' do
    post admin_make_models_merge_preview_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_select_params(@select_models)
    @select_models.each do |mm|
      assert_select('ul.make-model-airplanes-list li',
          /#{mm.make}, #{mm.model}/) do
        mm.airplanes.each do |airplane|
          assert_select('ul li', /#{airplane.id}: #{airplane.reg}/)
        end
      end
    end
  end

  test 'authorized preview merge with none selected will redirect' do
    post admin_make_models_merge_preview_path,
      headers: http_auth_login(:curator)
    assert_redirected_to admin_make_models_path
  end

  test 'authorized can show' do
    get admin_make_model_path(@models.first),
      headers: http_auth_login(:curator)
    assert_response :success
  end
end
