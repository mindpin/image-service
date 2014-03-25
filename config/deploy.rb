require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, '106.186.119.248'
set :deploy_to, '/web/image-service'
set :current_path, 'current'
set :repository, 'git://github.com/mindpin/image-service.git'
set :branch, 'master'
set :user, 'root'

set :shared_paths, [
  'config/mongoid.yml',
  'config/env.yml',
  'config/output_settings.yml',
  'tmp'
]

task :environment do
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/logs"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/logs"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]
  queue! %[touch "#{deploy_to}/shared/config/mongoid.yml"]
  queue! %[touch "#{deploy_to}/shared/config/env.yml"]

  queue  %[echo "-----> Be sure to edit 'shared/config/mongoid.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/env.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/output_settings.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue! "bundle"

    to :launch do
      queue! "RACK_ENV=production bundle exec rake assetpack:build"      
      queue %[
        source /etc/profile
        ./deploy/sh/sidekiq.sh stop
        ./deploy/sh/sidekiq.sh start
        ./deploy/sh/unicorn.sh stop
        ./deploy/sh/unicorn.sh start
      ]
    end
  end
end

desc "update code only"
task :update_code => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue! "bundle"

    to :launch do
      queue! "RACK_ENV=production bundle exec rake assetpack:build"      
    end

  end
end

desc "restart server"
task :restart => :environment do
  queue %[
    source /etc/profile
    cd #{deploy_to}/#{current_path}
    ./deploy/sh/sidekiq.sh stop
    ./deploy/sh/sidekiq.sh start
    ./deploy/sh/unicorn.sh stop
    ./deploy/sh/unicorn.sh start
  ]
end

