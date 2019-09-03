require 'test_helper'
require 'shared/make_models_data'

class Admin::MakeModelEditTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  setup do
    @models = setup_make_models_with_airplanes
    @to_edit = @models[Random.rand(@models.length)]
  end

  def update_params(mm)
    {
      "make_model"=> mm.attributes,
      "commit"=>"Update"
    }
  end

  test 'unauthorized cannot edit' do
    get edit_admin_make_model_path(@to_edit)
    assert_response :unauthorized
  end

  test 'unauthorized cannot update' do
    patch admin_make_model_path(@to_edit), params: update_params(@to_edit)
    assert_response :unauthorized
  end

  test 'authorized can update' do
    patch admin_make_model_path(@to_edit),
      params: update_params(@to_edit),
      headers: http_auth_login(:curator)
    assert_redirected_to admin_make_models_path
    get admin_make_models_path, headers: http_auth_login(:curator)
    assert_select('div#notice', /Updated #{@to_edit.make}, #{@to_edit.model}/)
  end

  test 'authorized can edit' do
    get edit_admin_make_model_path(@to_edit),
      headers: http_auth_login(:curator)
    assert_response :success
    assert_select(
      "form[action=\"#{admin_make_model_path(@to_edit)}\"]"
    ) do |form|
      form = form.first
      input = form.xpath(
        './/input[@type="text" and @name="make_model[make]" and ' +
        "@value=\"#{@to_edit.make}\"]"
      )
      assert_equal(1, input.length, "Have make")
      input = form.xpath(
        './/input[@type="text" and @name="make_model[model]" and ' +
        "@value=\"#{@to_edit.model}\"]"
      )
      assert_equal(1, input.length, "Have model")
      input = form.xpath(
        './/input[@type="number" and @name="make_model[horsepower]" and ' +
        "@value=\"#{@to_edit.horsepower}\"]"
      )
      assert_equal(1, input.length, "Have horsepower")
      input = form.xpath(
        './/input[@type="number" and @name="make_model[seats]" and ' +
        "@value=\"#{@to_edit.seats}\"]"
      )
      assert_equal(1, input.length, "Have seats")
      input = form.xpath(
        './/input[@type="number" and @name="make_model[wings]" and ' +
        "@value=\"#{@to_edit.wings}\"]"
      )
      assert_equal(1, input.length, "Have wings")
      input = form.xpath(
        './/input[@type="number" and ' +
        '@name="make_model[empty_weight_lbs]" and ' +
        "@value=\"#{@to_edit.empty_weight_lbs}\"]"
      )
      assert_equal(1, input.length, "Have empty_weight_lbs")
      input = form.xpath(
        './/input[@type="number" and @name="make_model[max_weight_lbs]" and ' +
        "@value=\"#{@to_edit.max_weight_lbs}\"]"
      )
      assert_equal(1, input.length, "Have max_weight_lbs")
      assert_select('input[@type="submit"]')
    end
  end
end
