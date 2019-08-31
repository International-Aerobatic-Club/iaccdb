source 'https://rubygems.org'

gem 'rails', "~> 5.1.0"

gem 'mysql2'

gem 'puma', '~> 3.11'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jbuilder'

gem 'libxml-ruby'
gem 'jquery-rails'
gem 'chronic'
gem 'foundation-rails'

gem 'delayed_job'
gem 'delayed_job_active_record'

# memoization used sparingly where appropriate
gem 'memoist2'

# maintenance mode as rack middleware
# prefer server config; but this will work
gem 'turnout'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen'
  gem 'minitest-rails', '~> 3.0'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'faker'
  gem 'timecop'
  gem 'launchy'
  gem 'simplecov'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'shoulda-context'
  gem 'minitest-great_expectations'
end

group :production do
  gem 'daemons'
  # support for execjs asset precompilation
  gem 'therubyracer'
end
