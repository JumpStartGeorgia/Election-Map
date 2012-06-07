server "alpha.jumpstart.ge", :web, :app, :db, primary: true
set :application, "Election-Map-Staging"
set :user, "electiondata-staging"
set :ngnix_conf_file_loc, "staging/nginx.conf"
set :unicorn_init_file_loc, "staging/unicorn_init.sh"
set :git_project_name, "Election-Map"
set :rails_env, "staging" 

