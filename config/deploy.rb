####################################################################
##### SET ALL VARIABLES UNDER config/deploy/env.rb             #####
####################################################################

set :stages, %w(production staging)
set :default_stage, "staging" # if just run 'cap deploy'' the staging environment will be used

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

after "deploy", "deploy:cleanup" # keep only the last 5 releases


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

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{git_branch_name}`
      puts "WARNING: HEAD is not the same as origin/#{git_branch_name}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
