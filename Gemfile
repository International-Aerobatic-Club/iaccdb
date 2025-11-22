source 'https://rubygems.org'
ruby '~> 3.4'

gem 'rails', '~> 8.0'

gem 'puma', '~> 3.12'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jbuilder'
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'benchmark'


gem 'libxml-ruby'
gem 'jquery-rails'
gem 'chronic'
gem 'foundation-rails', '< 6.9.0'
gem 'ostruct'

gem 'delayed_job'
gem 'delayed_job_active_record'

# memoization used sparingly where appropriate
gem 'memoist2'

# maintenance mode as rack middleware
# prefer server config; but this will work
gem 'turnout'

# support for execjs asset precompilation
gem 'mini_racer'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'rubocop', require: false
end

group :development do
  gem 'listen'
  gem 'minitest-rails'
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
end
