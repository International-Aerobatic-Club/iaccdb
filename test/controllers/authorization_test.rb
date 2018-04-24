require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  test 'authorized admin gets admin role' do
    get '/admin/contests', nil, http_auth_login(:admin)
    assert_equal(:admin, @controller.current_role)
  end

  test 'authorized contest admin gets contest role' do
    contest = create(:contest)
    delete contest_path(contest), nil, http_auth_login(:contest_admin)
    assert_equal(:contest_admin, @controller.current_role)
  end

  test 'unauthorized visitor gets visitor role' do
    get '/'
    assert_equal(:visitor, @controller.current_role)
  end
end
