require 'test_helper'
require 'shared/make_models_data'

class Admin::MakeModelMergeTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  setup do
    @models = setup_make_models_with_airplanes
    select = []
    4.times do
      select << @models[Random.rand(@models.length)]
    end
    @select_models = select.uniq
  end

  def admin_make_models_merge_params(select_models, target)
    params = {
      "selected" => select_models.inject(Hash.new) do |hash, mm|
        hash[mm.id.to_s] = "1"
        hash
      end,
      "target" => target.id
    }
    params
  end

  test 'unauthorized cannot post merge' do
    post admin_make_models_merge_path,
      params: admin_make_models_merge_params(
        @select_models, @select_models.first)
    assert_response :unauthorized
  end

  test 'authorized can merge' do
    post admin_make_models_merge_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_merge_params(
        @select_models, @select_models.first)
    assert_response :redirect
  end

  test 'merge redirect contains flash notice' do
    target = @select_models.first
    post admin_make_models_merge_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_merge_params(@select_models, target)
    assert_redirected_to admin_make_models_path
    # follow_redirect! doesn't authorize
    get admin_make_models_path, headers: http_auth_login(:curator)
    assert_select('div#notice',
      /Merged airplanes into #{target.make}, #{target.model}/)
  end

  test 'merge removes all selected but target' do
    target = @select_models[Random.rand(@select_models.count)]
    remove_ids = @select_models.collect(&:id) - [target.id]
    post admin_make_models_merge_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_merge_params(@select_models, target)
    assert_response :redirect
    remove_ids.each do |rid|
      assert_nil(MakeModel.find_by(id: rid), "MakeModel #{rid} removed")
    end
  end

  test 'merge places all airplanes with target' do
    target = @select_models[Random.rand(@select_models.count)]
    airplane_ids = @select_models.collect(&:airplanes).collect(&:to_a).flatten.
      collect(&:id)
    post admin_make_models_merge_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_merge_params(@select_models, target)
    assert_response :redirect
    assert_equal(airplane_ids.sort, target.reload.airplanes.pluck(:id).sort)
  end

  test 'merge marks target as curated' do
    target = @select_models[Random.rand(@select_models.count)]
    airplane_ids = @select_models.collect(&:airplanes).collect(&:to_a).flatten.
      collect(&:id)
    post admin_make_models_merge_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_merge_params(@select_models, target)
    assert_response :redirect
    assert_equal(true, target.reload.curated)
  end

  test 'merge with only one selected returns bad request' do
    target = @select_models[Random.rand(@select_models.count)]
    post admin_make_models_merge_path,
      headers: http_auth_login(:curator),
      params: admin_make_models_merge_params([target], target)
    assert_response :bad_request
  end
end
