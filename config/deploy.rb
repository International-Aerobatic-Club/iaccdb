set :application, 'cdb'
set :user, 'wbreezec'
set :domain, 'wbreeze.com'

# file paths
set :repository,  "#{user}@#{domain}:~/.git/#{application}.git"
set :deploy_to, "~/rails/#{application}"

role :app, domain
role :web, domain
role :db, domain, :primary => true

default_environment['PATH']='~/bin:/usr/bin:/bin'

set :deploy_via, :copy
set :scm, 'git'
set :scm_command, '~/bin/git'
set :local_scm_command, '~/bin/git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

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

