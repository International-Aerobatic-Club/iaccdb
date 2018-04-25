require 'test_helper'

class AuthHelperTest < ActiveSupport::TestCase
  include AuthHelper

  setup do
    UserList.users = [
      { 'name' => 'admin', 'password' => 'admin', 'role' => 'admin' },
      { 'name' => 'contest', 'password' => 'contest',
        'role' => 'contest_admin' },
      { 'name' => 'curator', 'password' => 'curator', 'role' => 'curator' }
    ]
  end

  test 'never allows unidentified' do
    refute(check_auth('missing', 'missing'))
    refute(check_auth('missing', 'missing', nil))
    refute(check_auth('missing', 'missing', []))
    refute(check_auth('missing', 'missing', :curator))
    refute(check_auth('missing', 'missing', :contest_admin))
  end

  test 'never allows bad password' do
    refute(check_auth('admin', 'bad'))
    refute(check_auth('admin', 'bad', nil))
    refute(check_auth('admin', 'bad', []))
    refute(check_auth('admin', 'bad', :curator))
    refute(check_auth('admin', 'bad', :contest_admin))
  end

  test 'always allows admin' do
    assert(check_auth('admin', 'admin'))
    assert(check_auth('admin', 'admin', nil))
    assert(check_auth('admin', 'admin', []))
    assert(check_auth('admin', 'admin', :curator))
    assert(check_auth('admin', 'admin', :contest_admin))
    assert(check_auth(
      'admin', 'admin', [:curator, :contest_admin])
    )
  end

  test 'requires contest admin' do
    refute(check_auth('contest', 'contest'))
    refute(check_auth('contest', 'contest', nil))
    refute(check_auth('contest', 'contest', []))
    refute(check_auth('contest', 'contest', :curator))
    assert(check_auth('contest', 'contest', :contest_admin))
    assert(check_auth(
      'contest', 'contest', [:curator, :contest_admin])
    )
  end

  test 'requires curator' do
    refute(check_auth('curator', 'curator'))
    refute(check_auth('curator', 'curator', nil))
    refute(check_auth('curator', 'curator', []))
    assert(check_auth('curator', 'curator', :curator))
    refute(check_auth('curator', 'curator', :contest_admin))
    assert(check_auth(
      'curator', 'curator', [:curator, :contest_admin])
    )
  end
end
