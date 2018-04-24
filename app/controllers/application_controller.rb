class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception

  def current_role
    @current_role || :visitor
  end

  def current_ability
    @current_ability ||= Ability.new(current_role)
  end

  # authenticate interactively with browser credentials query
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      do_auth(user_name, password)
    end
  end

  # authenticate non-interactively
  def api_authenticate
    authenticate_with_http_basic do |user_name, password|
      do_auth(user_name, password)
    end
  end

  #######
  private
  #######

  def do_auth(user_name, password)
    users = AuthHelper::Creds.read_users
    user = users ? users.find { |u| u['name'] == user_name } : nil
    have_auth = user && user['password'] == password
    @current_role = have_auth ? user['role'].to_sym : nil
    have_auth
  end
end
