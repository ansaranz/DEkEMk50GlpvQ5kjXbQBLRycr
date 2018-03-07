#!/bin/bash
#KuwaitNET
#CPU Usage Check of Docker Containers

LINE_NUM=1
docker stats --no-stream | grep -v CONTAINER | awk '{print $1,$2,$3}' > /tmp/CONTAINER_CPU_USAGE
CHECK=$(cat /tmp/CONTAINER_CPU_USAGE | awk '{print $3}' | cut -d'%' -f1 | cut -d'.' -f1)

for i in $CHECK
do
	j=$(sed -n "$LINE_NUM p" /tmp/CONTAINER_CPU_USAGE)
	let LINE_NUM++
	if [ $i -ge 70 ]; then
	echo -e "$j" >> /tmp/CONTAINER_CRITICAL
	fi
done

echo -e "High CPU Usage in server $(hostname) \n Container Details: \n$(cat /tmp/CONTAINER_CRITICAL)" | mail -s "$(hostname): Critical CPU Usage on docker container" amjath.sha@ahliunited.com

rm /tmp/CONTAINER_CPU_USAGE
rm /tmp/CONTAINER_CRITICAL

exit 0
