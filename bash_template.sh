#!/bin/bash
################################################
# author: Ben Li                               #
# date: 2018.02.01                             #
# a common shell script template which can be  #
# executed like ./xxxx start/stop              #
################################################
NAME="script_name"
LOGFILE=/tmp/$NAME.log
PIDFILE=/tmp/$NAME.pid
appName=$NAME 
. /etc/rc.d/init.d/functions 

function run(){
# to be implemented
exit 0
}

function start(){
    if [ -f "$PIDFILE" ]; then
        echo $PIDFILE "already exists!"
        exit 2
    fi
	echo "0" > $COUNTERFILE
    for (( ; ; ))
    do
        run
        sleep $interval
    done &
    if [ $? -eq 0 ]; then
            action $"Starting $appName: " /bin/true
        else
            action $"Starting $appName: " /bin/false
        fi
    echo $! > $PIDFILE
}

function stop(){
    [ -f $PIDFILE ] && kill `cat $PIDFILE`
    if [ $? -eq 0 ]; then
        action $"Stopping $appName: " /bin/true
    else
        action $"Stopping $appName: " /bin/false
    fi
    rm -rf $PIDFILE
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart}"
    exit 2
esac
exit $?	
