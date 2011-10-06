source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'nokogiri'

group :development, :test do
  gem 'sqlite3-ruby', "= 1.2.5", :require => 'sqlite3'
end

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
end

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
group :test do
  gem 'ruby-debug'
# gem 'ruby-debug19'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :production do
  gem 'mysql2'
end
