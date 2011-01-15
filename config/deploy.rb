set :application, 'cdb'
set :user, 'wbreezec'
set :domain, 'wbreeze.com'

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :scm, :git
set :repository, "#{user}@#{domain}:~/.git/#{application}.git"
set :branch, 'master'
set :deploy_via, :remote_cache
set :deploy_to, "~/rails/#{application}"
set :scm_verbose, true
set :use_sudo, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code", :bundle_install
desc "install prerequisite gems"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"
end

