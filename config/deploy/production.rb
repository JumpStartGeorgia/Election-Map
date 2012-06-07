set :application, "Election-Map"
set :user, "electiondata"
set :ngnix_conf_file_loc, "production/nginx.conf"
set :unicorn_init_file_loc, "production/unicorn_init.sh"
server "alpha.jumpstart.ge", :web, :app, :db, primary: true

