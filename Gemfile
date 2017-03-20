source 'https://rubygems.org'

#####
# to remove, holding rake back from 12.0.0
gem 'rake', "~> 11.0"
#####

gem 'rails', "~> 4.0"

##
# Transition to Rails 4.0
# Migrate away from this
# Currently, delayed_job still wants it
gem 'protected_attributes'
#####

gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'libxml-ruby'
gem 'jquery-rails'
gem 'chronic'
gem 'foundation-rails'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jbuilder'

# memoization used sparingly where appropriate
gem 'memoist2'

# maintenance mode as rack middleware
# prefer server config; but this will work
gem 'turnout'

gem 'mysql2'

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'forgery'
  gem 'capybara'
  gem 'launchy'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
end

group :production do
  gem 'daemons'
  # support for execjs asset precompilation
  gem 'therubyracer'
end
