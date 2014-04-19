source 'http://rubygems.org'

gem 'rails', "~> 3.0.0"

gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'libxml-ruby'

gem 'jquery-rails'

gem 'chronic'

group :development, :test do
  gem 'sqlite3-ruby', "= 1.2.5", :require => 'sqlite3'
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
