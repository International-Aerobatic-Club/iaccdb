source 'http://rubygems.org'

gem 'rails', "~> 4.1.0"

gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'libxml-ruby'
gem 'jquery-rails'
gem 'chronic'
gem 'zurb-foundation'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

group :development, :test do
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :development do
  gem 'nokogiri'
  #gem 'debugger'
end

group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :production do
  gem 'mysql2'
  gem 'daemons'
  # support for execjs asset precompilation
  gem 'therubyracer'
end

### Transition to Rails 4.0 - Migrate away from these
gem 'protected_attributes'
