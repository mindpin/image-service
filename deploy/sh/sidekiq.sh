#! /usr/bin/env bash

current_path=`cd "$(dirname "$0")"; pwd`
app_path=$current_path/../..
. $current_path/function.sh

pid=$app_path/tmp/pids/sidekiq.pid
log_file=$app_path/tmp/logs/sidekiq.log

cd $app_path

case "$1" in
  start)
    assert_process_from_pid_file_not_exist $pid
    nohup bundle exec sidekiq -q carrierwave -c 2 -e production -r ./lib/app.rb 1>> $log_file 2>> $log_file &
    echo $! > $pid
    echo "sidekiq start ............... $(command_status)"
  ;;
  status)
    check_run_status_from_pid_file $pid 'sidekiq'
  ;;
  stop)
    kill -9 `cat $pid`
    echo "sidekiq stop ................ $(command_status)"
  ;;
  restart)
    $0 stop
    sleep 1
    $0 start
  ;;
  *)
    echo "tip:(start|stop|restart|status|status)"
    exit 5
  ;;
esac
exit 0
