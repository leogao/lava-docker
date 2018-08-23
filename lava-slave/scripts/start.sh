#!/bin/bash

main() {
	echo "Waiting for lava-slave to be active"
	loop=10
	while (( $(ps -ef | grep -v grep | grep lava-slave | wc -l) == 0 ))
	do
		# Set LAVA Master IP
		if [[ -n "$LAVA_MASTER" ]]; then
			sed -i -e "s/{LAVA_MASTER}/$LAVA_MASTER/g" /etc/lava-dispatcher/lava-slave
		fi
		systemctl restart tftpd-hpa
		# FIXME lava-slave does not run if old pid is present
		rm -f /var/run/lava-slave.pid
		systemctl restart lava-slave
		if [[ $loop -le 0 ]]; then
			echo "Failed to start lava-slave"
			break
		else
			loop=$((loop-1))
		fi
		sleep 3
	done
	cd /opt/lava-extra/additions && bash setup_lava.sh
	systemctl restart lava-slave || exit 5
}

main
# start an http file server for boot/transfer_overlay support
(cd /var/lib/lava/dispatcher; python -m SimpleHTTPServer 80 &)
