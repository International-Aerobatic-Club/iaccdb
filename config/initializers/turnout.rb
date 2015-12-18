Turnout.configure do |config|
  config.app_root = '.'
  config.named_maintenance_file_paths = {app: 'tmp/maint.yml', server: '/tmp/server.yml'}
  config.default_maintenance_page = Turnout::MaintenancePage::HTML
  config.default_reason = 'Updates in progress'
  config.default_allowed_paths = ['^/assets/']
  config.default_response_code = 418
  config.default_retry_after = 3600
end

