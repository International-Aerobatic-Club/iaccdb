# http://stackoverflow.com/questions/3768718/rails-rspec-make-tests-pass-with-http-basic-authentication
module AuthHelper
  class Creds
    attr_reader :user, :password

    def initialize(role)
      creds = YAML.load_file('config/admin.yml')
      creds_role = creds[role]
      admin = Rails.application.secrets[role]
      @user = admin ? admin[:user] :
        (creds_role ? creds_role['user'] : creds[:user])
      @password = admin ? admin[:password] :
        (creds_role ? creds_role['password'] : creds[:password])
    end

    def http_auth_basic
      ActionController::HttpAuthentication::Basic.encode_credentials(
        user, password)
    end
  end

  module Controller
    def http_auth_login(role = 'admin')
      creds = Creds.new(role)
      request.env['HTTP_AUTHORIZATION'] = creds.http_auth_basic
    end
  end

  module Request
    # env = environment hash for use in the request
    # returns same with HTTP_AUTHORIZATION header added
    # e.g. `get path, {}, http_auth_login` or
    # `get path, {}, http_auth_login({ header_var: 'header_value' })`
    def http_auth_login(role = 'admin', env = nil)
      env ||= {}
      creds = Creds.new(role)
      env['HTTP_AUTHORIZATION'] = creds.http_auth_basic
      env
    end
  end

  module Feature
    class DriverAuthException < StandardError ; end
    def http_auth_login(role = 'admin')
      creds = Creds.new(role)
      driver = page.driver
      if driver.respond_to?(:basic_auth)
        driver.basic_auth(creds.user, creds.password)
      elsif driver.respond_to?(:basic_authorize)
        driver.basic_authorize(creds.user, creds.password)
      elsif driver.respond_to?(:header)
        driver.header('AUTHORIZATION', creds.http_auth_basic)
      elsif driver.respond_to?(:browser) && driver.browser.respond_to?(:basic_authorize)
        driver.browser.basic_authorize(creds.user, creds.password)
      elsif driver.respond_to?(:browser) && driver.browser.respond_to?(:authenticate)
        driver.browser.authenticate(creds.user, creds.password)
      else
        raise DriverAuthException.new "Capybara page driver basic auth unknown method"
      end
    end
    def basic_auth_visit(path)
      begin
        http_auth_login
        visit(path)
      rescue DriverAuthException
        creds = Creds.new
        session = Capybara.current_session
        cred_path = "http://#{creds.user}:#{creds.password}@#{session.server.host}:#{session.server.port}#{path}"
        visit(cred_path)
      end
    end
  end
end

RSpec.configure do |config|
  config.include AuthHelper::Controller, :type => :controller
  config.include AuthHelper::Request, :type => :request
  config.include AuthHelper::Feature, :type => :feature
end

