server "alpha.jumpstart.ge", :web, :app, :db, primary: true
set :application, "Election-Map"
set :user, "electiondata"
set :ngnix_conf_file_loc, "production/nginx.conf"
set :unicorn_init_file_loc, "production/unicorn_init.sh"
set :git_project_name, "Election-Map"
set :rails_env, "production" 


