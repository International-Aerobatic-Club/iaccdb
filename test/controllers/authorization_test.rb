require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  test 'authorized admin gets admin role' do
    get '/admin/contests', headers: http_auth_login(:admin)
    assert_response(:success)
    assert_equal(:admin, @controller.current_role)
  end

  test 'authorized contest admin gets contest role' do
    contest = create(:contest)
    delete contest_path(contest), headers: http_auth_login(:contest_admin)
    assert_response(:success)
    assert_equal(:contest_admin, @controller.current_role)
  end

  test 'unauthorized visitor gets visitor role' do
    get '/'
    assert_response(:success)
    assert_equal(:visitor, @controller.current_role)
  end
end
