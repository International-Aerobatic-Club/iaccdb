set :application, 'cdb'
set :user, 'iaccdbor'
set :domain, 'iaccdb.org'

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :scm, :git
set :repository, "#{user}@#{domain}:~/git/#{application}.git"
set :branch, 'master'
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{user}/rails/#{application}"
set :scm_verbose, true
set :use_sudo, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "cd /home/#{user}; rm -rf public_html; ln -s #{current_path}/public ./public_html"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code", :bundle_install
desc "install prerequisite gems"
task :bundle_install, :roles => :app do
  run "echo #{shared_path}"
  run "cd #{release_path} && bundle install --deployment"
end

# enable passenger
after "deploy:symlink", :enable_passenger
desc "setup .htaccess for passenger"
task :enable_passenger, :roles => :app do
  run "echo #{current_path}"
  #run "echo -e \"PassengerEnabled On\\nPassengerAppRoot #{current_path}\\nPassengerRuby $MY_RUBY_HOME/bin/ruby\" > #{File.join(current_path, 'public', '.htaccess')}"
  run "echo -e \"PassengerEnabled On\\nPassengerAppRoot #{current_path}\" > #{File.join(current_path, 'public', '.htaccess')}"
  run "rm -f ~/public_html && ln -s #{File.join(current_path, 'public')} ~/public_html"
end

