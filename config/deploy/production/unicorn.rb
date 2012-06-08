root = "/home/electiondata/Election-Map/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.Election-Map.sock"
listen 8081, :tcp_nopush => true # must be unique port # for each app
worker_processes 2
timeout 30
