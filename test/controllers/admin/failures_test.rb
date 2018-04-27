require 'test_helper'

class Admin::FailuresTest < ActionDispatch::IntegrationTest
  setup do
    @fail_list = create_list(:failure, 12)
  end

  test 'unauthorized request cannot list' do
    get admin_failures_path
    assert_response(:unauthorized)
  end

  test 'unathorized cannot show' do
    get admin_failure_path(@fail_list.first)
    assert_response(:unauthorized)
  end

  test 'unathorized cannot destroy' do
    delete admin_failure_path(@fail_list.first)
    assert_response(:unauthorized)
  end

  test 'authorized can list' do
    get admin_failures_path, headers: http_auth_login(:admin)
    assert_response(:success)
  end

  test 'authorized can show' do
    get admin_failure_path(@fail_list.first), headers: http_auth_login(:admin)
    assert_response(:success)
  end

  test 'authorized can delete' do
    delete admin_failure_path(@fail_list.first), headers: http_auth_login(:admin)
    assert_response(:redirect)
    assert_empty(Failure.where(id: @fail_list.first))
  end
end
