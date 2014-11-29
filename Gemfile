source 'http://rubygems.org'

gem 'rails', "~> 3.2.0"

gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'libxml-ruby'

gem 'jquery-rails'

gem 'chronic'

group :assets do
  gem 'sass-rails', "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end

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
