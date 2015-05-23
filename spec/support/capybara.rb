# Configure Capybara
# https://github.com/jnicklas/capybara
Capybara.configure do |config|
  #config.wait_on_first_by_default = true # on master, coming in the future
  #config.javascript_driver = :selenium # default
  config.javascript_driver = :webkit
  #config.default_wait_time = 15
end
