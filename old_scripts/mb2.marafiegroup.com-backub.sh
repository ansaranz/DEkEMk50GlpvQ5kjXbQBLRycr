#!/bin/bash

set -u
set -e 

MAILTO="ahmed.alshirbiny@kuwaitnet.com"
day=$(date +%a)
BACKUP_SIZE=45000000
#BACKUP_SIZE=50
CURRENT_SIZE=$(df /backup/ | tail -1 | awk '{ print $4  }')


#fail if there's no space available
if [ $BACKUP_SIZE -gt  $CURRENT_SIZE ]; then
    mail -s "Not enough space to complete backup" $MAILTO <<< "Not enough space to complete backup on $(hostname)"
    echo "FAIL"
    exit 1
fi

#stoping zimbra
systemctl stop zimbra

#remove old backup
rsync -Pavu --delete /opt/zimbra/ /backup/daily/zimbra/
#start zimbra again
systemctl start zimbra

#remove old backup
rm -rf /backup/$day.tar.gz

#compress backup
cd /backup && tar czf $day.tar.gz daily

if [ $? -eq 0  ]; then
    mail -s "Daily update completed on $(hostname)" $MAILTO <<< "Backup completed on server $(hostname) $(ls -al /backup)"
fi

