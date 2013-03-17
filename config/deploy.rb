require 'delayed/recipes'

set :user, 'iaccdbor'
set :domain, 'iaccdb.org'
set :application, 'cdb'
set :repository, "#{user}@#{domain}:~/git/#{application}.git"
set :deploy_to, "/home/#{user}/rails/#{application}"
default_run_options[:pty] = true

set :scm, :git
set :rake, 'bundle exec rake'

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :deploy_via, :remote_cache
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# enable passenger
after "deploy:create_symlink", :enable_passenger
desc "setup .htaccess for passenger"
task :enable_passenger, :roles => :app do
  run "echo -e \"PassengerEnabled On\\nPassengerAppRoot #{current_path}\" >> #{File.join(current_path, 'public', '.htaccess')}"
  run "rm -f ~/public_html && ln -s #{File.join(current_path, 'public')} ~/public_html"
end

# link admin credentials
after "deploy:create_symlink", :config_admin
desc "configure admin priveleges"
task :config_admin, :roles => :app do
  run "ln ~/admin.yml #{File.join(current_path, 'config/admin.yml')}"
end

# link database credentials
after "deploy:create_symlink", "db:config_access"
desc "configure database access priveleges"
namespace :db do
  task :config_access, :except => { :no_release => true }, :role => :app do
    run "rm #{File.join(current_path, 'config/database.yml')}"
    run "ln ~/database.yml #{File.join(current_path, 'config/database.yml')}"
  end
end

# install bundle
after "deploy:update_code", :bundle_install
desc "install prerequisite gems from Gemfile.lock"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install --deployment"
end

# delayed_job
set :rails_env, "production"
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

