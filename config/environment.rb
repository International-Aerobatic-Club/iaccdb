# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  delivery_method: :smtp,
  address: Rails.application.credentials.dig(:smtp_server, :host_name),
  port: Rails.application.credentials.dig(:smtp_server, :host_port),
  user_name: Rails.application.credentials.dig(:smtp_server, :user_id),
  password: Rails.application.credentials.dig(:smtp_server, :password),
  authentication: :login,
  enable_starttls_auto: true,
}
