#! /usr/bin/env bash

current_path=`cd "$(dirname "$0")"; pwd`
app_path=$current_path/../..
. $current_path/function.sh

pid=$app_path/tmp/pids/unicorn.pid

cd $app_path
echo "######### info #############"
echo "pid_file_path $pid"
echo "app_path $(pwd)"
echo "############################"

case "$1" in
  start)
    assert_process_from_pid_file_not_exist $pid
    bundle exec unicorn -c config/unicorn.rb -E production -D
    echo "app start .............$(command_status)"
  ;;
  status)
    check_run_status_from_pid_file $pid 'app'
  ;;
  stop)
    kill `cat $pid`
    echo "app stop .............$(command_status)"
  ;;
  usr2_stop)
    echo "usr2_stop"
    kill -USR2 `cat $pid`
    command_status
  ;;
  *)
    echo "tip:(start|stop|usr2_stop|status)"
    exit 5
  ;;
esac

exit 0


