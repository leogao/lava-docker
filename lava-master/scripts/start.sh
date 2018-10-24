#!/bin/bash

start_service () {
	echo "Starting $1"
	if (( $(ps -ef | grep -v grep | grep -v add_device | grep -v dispatcher-config | grep "$1" | wc -l) > 0 ))
	then
		echo "$1 appears to be running"
	else
		systemctl start "$1"
	fi
}


main() {
	# Setting timezone as Asia/Shanghai
	timedatectl set-timezone  Asia/Shanghai
	echo "Waiting for lavaserver database to be active"
	while (( $(ps -ef | grep -v grep | grep postgres | grep lavaserver | wc -l) == 0 ))
	do
		start_service postgresql
		start_service apache2
		start_service lava-master
		start_service lava-coordinator
		start_service lava-slave
		start_service lava-server-gunicorn
		start_service tftpd-hpa
		echo -n "."
		sleep 1
	done
	echo 
	echo "[ ok ] LAVA server ready"
}

#remove lava-pid files incase the image is stored without first stopping the services
rm -f /var/run/lava-*.pid 2> /dev/null

main
cd /opt/lava-extra/additions && bash setup_lava.sh
#added after the website not running a few times on boot
systemctl reload apache2 
systemctl restart cron
