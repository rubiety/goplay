set :application, "goplay"
set :repository, "git@github.com:railsgarden/goplay.git"

set :scm, :git
set :branch, 'origin/master'

task :production do
	role :web, "cedar.synenterprises.com"
	role :app, "cedar.synenterprises.com"
	role :db,  "cedar.synenterprises.com", :primary => true

	set :rails_env, "production"
	set :deploy_to, "/var/www/goplay.rubiety.com/app"
	set :user, "bhughes"
	set :use_sudo, false
end

namespace :deploy do
  task :restart do
	  restart_merb
	end
	
	task :start do
		start_merb
	end
	
	task :stop do
		stop_merb
	end
	
	task :restart_merb do
		stop_merb
		start_merb
	end
	
	task :start_merb do
		run "cd #{release_path}; merb -e production -c 1 -L log/merb.log"
	end
	
	task :stop_merb do
		run "cd #{release_path}; merb -K all"
	end
	
end

after "deploy:update_code", :create_permissions
after "deploy:update_code", :create_shared_links

task :create_permissions do
  run "find #{release_path}/public -type d -exec chmod 0755 {} \\;" 
  run "find #{release_path}/public -type f -exec chmod 0644 {} \\;"
  run "chmod 0755 #{release_path}/public/merb.fcgi" 
end

task :create_shared_links do
  run "cd #{release_path}/config && ln -nfs ../../../shared/config/database.yml database.yml"
end
