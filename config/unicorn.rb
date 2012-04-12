worker_processes 2
user 'deployer'

preload_app true
timeout 30

working_directory "/home/deployer/Election-Map/current"
listen "/tmp/app.socket", :backlog => 64

pid "/home/deployer/Election-Map/shared/pids/unicorn.pid"
stderr_path "/home/deployer/Election-Map/current/log/unicorn.stderr.log"
stdout_path "/home/deployer/Election-Map/current/log/unicorn.stdout.log"

