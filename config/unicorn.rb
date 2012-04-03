# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

working_directory "/home/jasonaddie/Projects/Election-Map/"
listen 3000 # by default Unicorn listens on port 8080
worker_processes 2 # this should be >= nr_cpus
pid "/home/jasonaddie/Projects/Election-Map/tmp/pids/unicorn.pid"
stderr_path "/home/jasonaddie/Projects/Election-Map/log/unicorn.log"
stdout_path "/home/jasonaddie/Projects/Election-Map/log/unicorn.log"

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
