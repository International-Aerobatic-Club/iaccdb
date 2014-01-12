require 'delayed/recipes'
require 'bundler/capistrano'

set :user, 'webmaster'
set :domain, 'iac.org'
set :application, 'iaccdb'
set :repository, 'https://github.com/wbreeze/iaccdb.git'
set :deploy_to, "/home/#{user}/#{application}"
default_run_options[:pty] = true

set :scm, :git
set :bundle_flags, "--deployment --quiet --binstubs"
set :default_environment, {
  'PATH' => "$HOME/iaccdb/.rbenv/shims:$HOME/iaccdb/.rbenv/bin:$PATH"
}

role :app, domain
role :web, domain
role :db, domain, :primary => true

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

# link admin credentials
after "deploy:create_symlink", :config_admin
desc "configure admin priveleges"
task :config_admin, :roles => :app do
  run "ln #{File.join(deploy_to, '/admin.yml')} #{File.join(current_path, 'config/admin.yml')}"
end

# link database credentials
after "deploy:create_symlink", "db:config_access"
desc "configure database access priveleges"
namespace :db do
  task :config_access, :except => { :no_release => true }, :role => :app do
    run "rm #{File.join(current_path, 'config/database.yml')}"
    run "ln #{File.join(deploy_to, '/database.yml')} #{File.join(current_path, 'config/database.yml')}"
  end
end

# install bundle
#after "deploy:update_code", :bundle_install
#desc "install prerequisite gems from Gemfile.lock"
#task :bundle_install, :roles => :app do
  #run "cd #{release_path} && bundle install --deployment"
#end

# delayed_job
#set :rails_env, "production"
#after "deploy:stop",    "delayed_job:stop"
#after "deploy:start",   "delayed_job:start"
#after "deploy:restart", "delayed_job:restart"

