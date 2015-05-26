#! /usr/bin/env bash

current_path=`cd "$(dirname "$0")"; pwd`

app_path=$current_path/../..
. $current_path/function.sh

pid=$app_path/tmp/pids/sidekiq.pid
log=$app_path/tmp/logs/sidekiq.log

case "$1" in
  start)
    assert_process_from_pid_file_not_exist $pid
    cd $current_path/../../
    nohup bundle exec sidekiq -e production 1>> $log 2>> $log &
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
