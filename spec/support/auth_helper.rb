module AuthHelper
  class Creds
    attr_reader :user, :password
    def initialize
      creds = YAML.load_file('config/admin.yml')
      @user = creds['user']
      @password = creds['password']
    end
  end

  module Controller
    def http_auth_login
      creds = Creds.new
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(creds.user, creds.password)
    end  
  end

  module Request
    # env = environment hash for use in the reuest
    # returns same with HTTP_AUTHORIZATION header added
    # e.g. `get path, {}, http_auth_login` or
    # `get path, {}, http_auth_login({ header_var: 'header_value' })`
    def http_auth_login(env = nil)
      env ||= {}
      creds = Creds.new
      env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(creds.user, creds.password)
      env
    end
  end

  module Feature
    def http_auth_login
      creds = Creds.new
      if page.driver.respond_to?(:basic_auth)
        page.driver.basic_auth(creds.user, creds.password)
      elsif page.driver.respond_to?(:basic_authorize)
        page.driver.basic_authorize(creds.user, creds.password)
      elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
        page.driver.browser.basic_authorize(creds.user, creds.password)
      else
        raise "Capybara page driver basic auth unknown"
      end
    end
  end
end

RSpec.configure do |config|
  config.include AuthHelper::Controller, :type => :controller
  config.include AuthHelper::Request, :type => :request
  config.include AuthHelper::Feature, :type => :feature
end

