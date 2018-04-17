class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      creds = YAML.load_file('config/admin.yml')
      user_name == creds['user'] && password == creds['password']
    end
  end

  def check_credentials(role = 'contest_admin')
    has_auth = authenticate_with_http_basic do |user_name, password|
      creds = Rails.application.secrets[role] ||
        YAML.load_file('config/admin.yml')[role]
      creds && user_name == creds['user'] && password == creds['password']
    end
    head :unauthorized unless has_auth
  end
end
