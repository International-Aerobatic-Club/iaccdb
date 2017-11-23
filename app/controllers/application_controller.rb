class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      creds = YAML.load_file('config/admin.yml')
      user_name == creds['user'] && password == creds['password']
    end
  end

end
