class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == 'dclo' && password == 'metrics4iac'
    end
  end

end
