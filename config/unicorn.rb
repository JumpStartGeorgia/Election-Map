worker_processes 2
user 'deployer', 'staff'

preload_app true
timeout 30

working_directory "/home/deployer/Election-Map/current"
listen "/tmp/app.socket", :backlog => 64

pid "/home/deployer/Election-Map/current/pids/unicorn.pid"
stderr_path "/home/deployer/Election-Map/current/log/unicorn.stderr.log"
stdout_path "/home/deployer/Election-Map/current/log/unicorn.stdout.log"

