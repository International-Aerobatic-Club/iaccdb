namespace :db do
  namespace :test do
    desc "db:seed after db:test:prepare"
    task :prepare => :environment do
      Rake::Task['db:seed'].invoke
    end
  end
end
