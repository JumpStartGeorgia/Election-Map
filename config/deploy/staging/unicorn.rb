root = "/home/electiondata-staging/Election-Map-Staging/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.Election-Map-Staging.sock"
listen 8082, :tcp_nopush => true # must be unique port # for each app
worker_processes 2
timeout 30
