#!/bin/bash
sed -i -e "s/{LAVA_MASTER}/$LAVA_MASTER/g" /etc/lava-dispatcher/lava-slave
sed -i -e "s/localhost/$LAVA_MASTER/g" /etc/lava-coordinator/lava-coordinator.conf
exec /sbin/init 
