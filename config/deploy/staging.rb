set :application, "Election-Map-Staging"
set :user, "electiondata-staging"
set :ngnix_conf_file_loc, "staging/nginx.conf"
set :unicorn_init_file_loc, "staging/unicorn_init.sh"
server "alpha.jumpstart.ge", :web, :app, :db, primary: true

