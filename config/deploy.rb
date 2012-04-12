set :application, "Election-Map"
set :repository,  "git@github.com:JumpStartGeorgia/Election-Map.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "192.168.1.117"
role :app, "192.168.1.117"
role :db,  "192.168.1.117", :primary => true

set :deploy_to, "/home/deployer"
set :user, "deployer"
set :scm_username, "ericnbarrett"

server "election-map.jumpstart.ge", :app, :web, :db, :primary => true

set :default_environment, { 'PATH' => "/home/deployer/.rbenv/shims:/home/deployer/.rbenv/bin:$PATH" }
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
