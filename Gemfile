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
  gem 'sqlite3-ruby'
end

group :development do
  gem 'nokogiri'
  gem 'debugger'
end

group :test do
  gem 'rspec-rails', '~> 2.6.0'
  gem 'factory_girl_rails', '~> 1.2.0'
  gem 'database_cleaner'
end

group :production do
  gem 'mysql2'
  gem 'activerecord-mysql2-adapter'
  gem 'daemons'
end
