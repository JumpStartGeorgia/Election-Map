##################################
##### SET THESE VARIABLES ########
##################################
server "alpha.jumpstart.ge", :web, :app, :db, primary: true # server where app is located
set :application, "Election-Map" # unique name of application
set :user, "electiondata"# name of user on server
set :ngnix_conf_file_loc, "production/nginx.conf" # location of nginx conf file
set :unicorn_init_file_loc, "production/unicorn_init.sh" # location of unicor init shell file
set :git_project_name, "Election-Map" # name of git repo
set :rails_env, "production" # name of environment: production, staging, ... 
##################################


