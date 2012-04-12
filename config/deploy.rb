set :application, "Election-Map"
set :repository,  "git@github.com:JumpStartGeorgia/Election-Map.git"

default_run_options[:pty] = true
set :scm, :git

role :web, "192.168.1.117"
role :app, "192.168.1.117"
role :db,  "192.168.1.117", :primary => true

set :deploy_to, "/home/deployer/Election-Map"
set :user, "deployer"
set :scm_username, "ericnbarrett"
set :scm_passphrase, "begemot"
ssh_options[:forward_agent] = true
set :branch, "master"
set :use_sudo, false

server "192.168.1.117", :app, :web, :db, :primary => true

set :default_environment, { 'PATH' => "/home/deployer/.rbenv/shims:/home/deployer/.rbenv/bin:$PATH" }
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
