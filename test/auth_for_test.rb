module AuthForTest
  class Creds
    attr_reader :user, :password

    def initialize(role)
      fail("Attempted auth outside of test") unless Rails.env == "test"
      role_user = AuthHelper::UserList.first_with_role(role)
      @user = role_user ? role_user['name'] : nil
      @password = role_user ? role_user['password'] : nil
    end

    def http_auth_basic
      ActionController::HttpAuthentication::Basic.encode_credentials(
        user, password)
    end
  end

  # http://stackoverflow.com/questions/3768718/rails-rspec-make-tests-pass-with-http-basic-authentication
  module Controller
    def http_auth_login(role = :admin)
      creds = Creds.new(role)
      request.env['HTTP_AUTHORIZATION'] = creds.http_auth_basic
    end
  end

  module Request
    # env = environment hash for use in the request
    # returns same with HTTP_AUTHORIZATION header added
    # e.g. `get path, {}, http_auth_login` or
    # `get path, {}, http_auth_login({ header_var: 'header_value' })`
    def http_auth_login(role = :admin, env = nil)
      env ||= {}
      creds = Creds.new(role)
      env['HTTP_AUTHORIZATION'] = creds.http_auth_basic
      env
    end
  end

  module Feature
    class DriverAuthException < StandardError ; end
    def http_auth_login(role = :admin)
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
    def basic_auth_visit(path, role = :admin)
      begin
        http_auth_login(role)
        visit(path)
      rescue DriverAuthException => e
        creds = Creds.new(role)
        session = Capybara.current_session
        cred_path = "http://#{creds.user}:#{creds.password}@#{session.server.host}:#{session.server.port}#{path}"
        visit(cred_path)
      end
    end
  end
end
