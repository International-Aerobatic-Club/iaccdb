require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class Application < Rails::Application

  # Initialize configuration defaults for originally generated Rails version.
  config.load_defaults 5.1
  config.autoloader = :zeitwerk

  # Load the various files in 'services' and its subdirectories
  config.autoload_paths << Rails.root.join('app/services')
  config.autoload_paths << Rails.root.join('app/services/iac')
  config.autoload_paths << Rails.root.join('app/services/jasper')
  config.autoload_paths << Rails.root.join('app/services/jobs')
  config.autoload_paths << Rails.root.join('app/services/member_merge')
  config.autoload_paths << Rails.root.join('app/services/ranking')
  config.autoload_paths << Rails.root.join('app/services/tasks')

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

end
