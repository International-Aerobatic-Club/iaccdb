require 'test_helper'
require 'shared/make_models_data'

class Admin::MakeModelShowTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  setup do
    @models = setup_make_models_with_airplanes
    select = []
    4.times do
      select << @models[Random.rand(@models.length)]
    end
    @select_models = select.uniq
  end

  test 'unauthorized cannot show' do
    get admin_make_model_path(@models.first)
    assert_response :unauthorized
  end

  test 'authorized can show' do
    get admin_make_model_path(@models.first),
      headers: http_auth_login(:curator)
    assert_response :success
  end
end
