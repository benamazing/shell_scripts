#!/bin/bash
#################################################
#        create by Ben Li 2018/01/31            #
#  Monitor the load average, once exceeds the   #
#  thresholds for 5 times continuously, restart #
#  the specified app                            #
#################################################
NAME=loadAvgMon
LOGFILE=/tmp/$NAME.log
PIDFILE=/tmp/$NAME.pid
COUNTERFILE=/tmp/$NAME.count
appName="loadAvgMon"
. /etc/rc.d/init.d/functions
AppToBeStart="tika"
load_1min_threshold=10
load_5min_threshold=8

#check every 60 seconds
interval=60

function run(){
		load_avg_s=`uptime|awk -F":" '{print $NF}'`
		load_1min=`echo $load_avg_s | awk -F"," '{print $1}'`
		load_5min=`echo $load_avg_s | awk -F"," '{print $2}'`
		if [[ $load_1min>$load_1min_threshold && $load_5min>$load_5min_threshold ]]
		   then 
		   counter=`cat $COUNTERFILE`
		   counter=$((counter+1))
		   if [ $counter -eq 5 ]; then
		    dt=`date "+%Y-%m-%d %H:%M:%S"`
			echo $dt ": load average continuously exceeded the threshold for 5 times..." >> $LOGFILE
			echo $dt ": current load adverage is : " $load_1min, $load_5min >> $LOGFILE
			supervisorctl status $AppToBeStart >> $LOGFILE
			echo `date "+%Y-%m-%d %H:%M:%S"` : restarting $AppToBeStart >>$LOGFILE
			supervisorctl restart $AppToBeStart >> $LOGFILE
			supervisorctl status $AppToBeStart >> $LOGFILE
			counter=0
		   fi
		else
		   counter=0
		fi
		echo $counter > $COUNTERFILE
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
