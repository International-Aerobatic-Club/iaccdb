require 'test_helper'

module Admin
  class MembersControllerTest < ActionController::TestCase
    setup do
      @member_list = create_list(:member, 12)
      @before_attrs = @member_list.first.attributes
      @after_attrs = @before_attrs.merge(
        {'family_name' => Faker::Name.last_name}
      )
    end

    context 'deny non-admin' do
      should 'view index' do
        get :index
        assert_response :unauthorized
      end

      should 'show member' do
        get :show, params: { id: @member_list.first.id }
        assert_response :unauthorized
      end

      should 'patch update' do
        patch :update, params: { id: @after_attrs['id'], member: @after_attrs }
        assert_response :unauthorized
      end
    end

    context 'allow admin' do
      setup do
        http_auth_login(:admin)
      end

      should "get index" do
        get :index
        assert_response :success
      end

      should "get show" do
        get :show, params: { id: @member_list.first.id }
        assert_response :success
      end

      should "patch update" do
        patch :update, params: { id: @after_attrs['id'], member: @after_attrs }
        assert_response :redirect
        member = Member.find(@after_attrs['id'])
        assert_not_nil(member)
        assert_equal(@after_attrs['family_name'], member.family_name)
      end
    end
  end
end
