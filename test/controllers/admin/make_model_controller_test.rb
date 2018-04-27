require 'test_helper'

class Admin::MakeModelControllerTest < ActionDispatch::IntegrationTest
  setup do
    @models = create_list(:make_model, 4)
  end

  test 'unauthorized cannot view index' do
    get admin_make_models_path
    assert_response :unauthorized
  end

  test 'unauthorized cannot show' do
    get admin_make_model_path(@models.first)
    assert_response :unauthorized
  end

  test 'authorized can view index' do
    get admin_make_models_path, headers: http_auth_login(:curator)
    assert_response :success
  end

  test 'authorized can show' do
    get admin_make_model_path(@models.first),
      headers: http_auth_login(:curator)
    assert_response :success
  end
end
