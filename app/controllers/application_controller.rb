class ApplicationController < ActionController::Base
  include AuthHelper
  protect_from_forgery :with => :exception

  # authenticate interactively with browser credentials query
  def authenticate(role = nil)
    authenticate_or_request_with_http_basic do |user_name, password|
      check_auth(user_name, password, role)
    end
  end

  # authenticate non-interactively
  def api_authenticate(role = nil)
    authenticate_with_http_basic do |user_name, password|
      check_auth(user_name, password, role)
    end
  end
end
