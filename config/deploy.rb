####################################################################
##### SET ALL VARIABLES UNDER config/deploy/env.rb             #####
####################################################################

set :stages, %w(production staging)
set :default_stage, "staging" # if just run 'cap deploy' the staging environment will be used

require 'capistrano/ext/multistage' # so we can deploy to staging and production servers
require "bundler/capistrano" # Load Bundler's capistrano plugin.

# these vars are set in deploy/env.rb
#set :user, "placeholder"
#set :application, "placeholder"

set(:deploy_to) {"/home/#{user}/#{application}"}

set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set(:branch) {"#{git_branch_name}"}
set(:repository) {"git@github.com:#{github_account_name}/#{github_repo_name}.git"}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :keep_releases, 2
after "deploy", "deploy:cleanup" # remove the old releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/deploy/#{ngnix_conf_file_loc} /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/deploy/#{unicorn_init_file_loc} /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
		run "mkdir -p #{shared_path}/json"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/json #{release_path}/public/json"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  task :folder_cleanup, roles: :app do
#		puts "cleaning up release/db"
#		run "rm -rf #{release_path}/db/*"
		puts "cleaning up release/.git"
		run "rm -rf #{release_path}/.git/*"
  end
  after "deploy:finalize_update", "deploy:folder_cleanup"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{git_branch_name}`
      puts "WARNING: HEAD is not the same as origin/#{git_branch_name}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

=begin
	# taken from http://www.rostamizadeh.net/blog/2012/04/14/precompiling-assets-locally-for-capistrano-deployment/
	before 'deploy:finalize_update', 'deploy:assets:symlink'
	after 'deploy:update_code', 'deploy:assets:precompile'
	namespace :assets do
    task :precompile, :roles => :web do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ lib/assets/ app/assets/ | wc -l").to_i > 0
        puts "*****************"
        puts "Assets have changed, compiling locally and then copying to shared/assets folder on server"
        puts "*****************"
        run_locally("rake assets:clean && rake assets:precompile")
        run_locally "cd public && tar -jcf assets.tar.bz2 assets"
        top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
        run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
        run_locally "rm public/assets.tar.bz2"
        run_locally("rake assets:clean")
      else
        puts "*****************"
        puts "Skipping asset precompilation because there were no asset changes"
        puts "*****************"
      end
    end

    task :symlink, roles: :web do
      run ("rm -rf #{latest_release}/public/assets &&
            mkdir -p #{latest_release}/public &&
            mkdir -p #{shared_path}/assets &&
            ln -s #{shared_path}/assets #{latest_release}/public/assets")
    end
  end
=end

	namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      # Check if assets have changed. If not, don't run the precompile task - it takes a long time.
      force_compile = false
      changed_asset_count = 0
      begin
        from = source.next_revision(current_revision)
        asset_locations = 'app/assets/ lib/assets vendor/assets'
        changed_asset_count = capture("cd #{latest_release} && #{source.local.log(from)} #{asset_locations} | wc -l").to_i
      rescue Exception => e
        logger.info "Error: #{e}, forcing precompile"
        force_compile = true
      end
      if changed_asset_count > 0 || force_compile
        logger.info "#{changed_asset_count} assets have changed; force_compile = #{force_compile}. Pre-compiling"
#        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
        puts "*****************"
        puts "Assets have changed, compiling locally and then copying to shared/assets folder on server"
        puts "*****************"
        run_locally("rake assets:clean && rake assets:precompile")
        run_locally "cd public && tar -jcf assets.tar.bz2 assets"
        top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
        run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
        run_locally "rm public/assets.tar.bz2"
        run_locally("rake assets:clean")
      else
        logger.info "#{changed_asset_count} assets have not changed. Skipping asset pre-compilation"
      end
    end
  end

end
