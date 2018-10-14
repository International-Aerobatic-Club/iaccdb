# Configure Capybara
# https://github.com/jnicklas/capybara

RSpec.configure do |config|
  # when viz: true is on the scenario, e.g.
  #   RSpec.describe "interface property", :type => :feature, viz: true do ...
  #   or
  #   scenario 'make it so', viz: true do ...
  # we force the selenium driver.
  # It will override the javascript driver as well, in other words
  # "viz: true" trumps "js:true"
  config.around :example, viz: true do |ex|
    hold_driver = Capybara.current_driver
    hold_javascript_driver = Capybara.javascript_driver
    Capybara.current_driver = :selenium
    Capybara.javascript_driver = :selenium
    ex.run
    Capybara.current_driver = hold_driver
    Capybara.javascript_driver = hold_javascript_driver
  end
end

