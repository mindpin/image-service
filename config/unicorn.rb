worker_processes 3
preload_app true
timeout 60

app_path = File.expand_path("../../", __FILE__)

listen "#{app_path}/tmp/sockets/unicorn.sock", :backlog => 2048
pid "#{app_path}/tmp/pids/unicorn.pid"

stderr_path("#{app_path}/tmp/logs/unicorn-error.log")
stdout_path("#{app_path}/tmp/logs/unicorn.log")