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

    test 'non-admin cannot view index' do
      get :index
      assert_response :unauthorized
    end

    test 'non-admin cannot show member' do
      get :show, id: @member_list.first.id
      assert_response :unauthorized
    end

    test 'non-admin cannot patch update' do
      patch :update, id: @after_attrs['id'], member: @after_attrs
      assert_response :unauthorized
    end

    test "admin get index" do
      get :index, parameters: {}
      assert_response :success
    end

    test "should get show" do
      get :show
      assert_response :success
    end

    test "admin can patch update" do
      patch :update, id: @after_attrs['id'], member: @after_attrs
      assert_response :success
    end

  end
end
