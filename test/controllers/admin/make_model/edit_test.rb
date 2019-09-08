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

  test 'authorized update sets values' do
    edit_model = build(:make_model, 
      make: 'Sol',
      model: 'Yellow Dwarf',
      wings: 2,
      seats: 2,
      horsepower: 400,
      max_weight_lbs: 2000,
      empty_weight_lbs: 1000,
      curated: true
    )
    patch admin_make_model_path(@to_edit),
      params: update_params(edit_model),
      headers: http_auth_login(:curator)
    assert_redirected_to admin_make_models_path
    @to_edit.reload
    %w[make model wings seats horsepower max_weight_lbs empty_weight_lbs
       curated].each do |attrib|
      assert_equal(edit_model.send(attrib), @to_edit.send(attrib))
    end
  end

  test 'update collision redirects to merge' do
    to_edit = @models[0]
    to_collide = @models[1]
    patch admin_make_model_path(to_edit),
      params: update_params(to_collide),
      headers: http_auth_login(:curator)
    assert_response :success
    assert_select('div#alert', /Make and model exists, suggesting a merge/)
    assert_select('ul.make-model-targets') do |ul|
      assert_select('li', /#{to_edit.make}, #{to_edit.model}/)
      input = ul.xpath(
        "./li/input[@type='radio' and @value='#{to_edit.id}']")
      assert_equal(1, input.length,
        "Radio button for #{to_edit.make}, #{to_edit.model}")
      assert_select('li', /#{to_collide.make}, #{to_collide.model}/)
      input = ul.xpath(
        "./li/input[@type='radio' and @value='#{to_collide.id}' and @checked]"
      )
      assert_equal(1, input.length,
        "Checked radio button for #{to_collide.make}, #{to_collide.model}"
      )
    end
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
        './/input[@type="radio" and @name="make_model[wings]" and @value="1"]'
      )
      assert_equal(1, input.length, "Have monoplane")
      input = form.xpath(
        './/input[@type="radio" and @name="make_model[wings]" and @value="2"]'
      )
      assert_equal(1, input.length, "Have biplane")
      input = form.xpath(
        './/input[@type="radio" and @name="make_model[wings]" and not(@value)]'
      )
      assert_equal(1, input.length, "Have wings undetermined")
      input = form.xpath(
        './/input[@type="radio" and @name="make_model[wings]" and ' +
        "@value=\"#{@to_edit.wings}\" and @checked]"
      )
      assert_equal(1, input.length, "Monoplane or biplane checked")
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
      input = form.xpath(
        './/input[@type="checkbox" and @name="make_model[curated]" and ' +
        '@checked]'
      )
      assert_equal(1, input.length, "Have curated checkbox checked")
      assert_select('input[@type="submit"]')
    end
  end
end
