require 'test_helper'

module Admin
  class ContestsControllerTest < ActionController::TestCase
    setup do
      @contest_list = create_list(:contest, 12)
      @contest = @contest_list.first
      @before_attrs = @contest.attributes
      @after_attrs = @before_attrs.merge(
        {
          'name' => contest_name,
          'city' => Faker::Address.city,
          'region' => region_name,
          'chapter' => chapter_number,
        }
      )
    end

    context 'deny non-admin' do
      should 'get index' do
        get :index
        assert_response :unauthorized
      end

      should 'patch update' do
        patch :update, params: { id: @after_attrs['id'], contest: @contest }
        assert_response :unauthorized
      end

      should 'destroy' do
        delete :destroy, params: { id: @contest.id }
        assert_response :unauthorized
      end
    end

    context 'allow admin' do
      setup do
        http_auth_login(:admin)
      end

      should 'get index' do
        get :index
        assert_response :success
      end

      should 'patch update' do
        patch :update, params: { id: @contest.id, contest: @after_attrs }
        assert_response :redirect
        @contest.reload
        assert_equal(@after_attrs['name'], @contest.name)
      end
    end
  end
end
