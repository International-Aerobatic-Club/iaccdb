source 'http://rubygems.org'

gem 'rails', "~> 3.0.0"

gem 'delayed_job_active_record', '= 0.4.2'

gem 'libxml-ruby'

gem 'jquery-rails'

group :development, :test do
  gem 'sqlite3-ruby', "= 1.2.5", :require => 'sqlite3'
end

group :development do
  # Deploy with Capistrano
  gem 'capistrano', '~> 2.0'
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
