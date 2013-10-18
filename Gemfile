source 'http://rubygems.org'

gem 'rails', "~> 3.0.0"

gem 'delayed_job_active_record', '= 0.4.2'

gem 'libxml-ruby'

group :development, :test do
  gem 'sqlite3-ruby', "= 1.2.5", :require => 'sqlite3'
end

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'nokogiri'
end

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
group :test do
  gem 'ruby-debug'
# gem 'ruby-debug19'
  gem 'rspec-rails', '~> 2.6.0'
  gem 'factory_girl_rails', '~> 1.2.0'
  gem 'database_cleaner'
end

group :production do
  gem 'mysql2', '~> 0.2.0'
  gem 'daemons'
end
