
#!/bin/bash

#Directory for RHC detail collection
mkdir /home/bb_02570/kuwaitnet-rhc-`hostname` && cd /home/bb_02570/kuwaitnet-rhc-`hostname` && pwd

###########################
mkdir 3.1 && cd 3.1
touch 3.1-Server-Hardware

echo "3.1.1---------"
dmidecode >> dmidecode

echo "3.1.2---------"
ifconfig -a > ifconfig-a

echo "3.1.3---------"
fdisk -l >> fdisk-l

echo "3.1.3---------"
multipath -ll >> multipath-ll

echo "3.1.4---------"
free -m >> free-m
vmstat >> vmstat
vmstat  -s -S m >> vmstat

###########################
cd .. && mkdir 3.2 && cd 3.2
touch 3.2-Installed-Software

echo "3.2.1---------"
cp -v /etc/redhat-release .
#cp -v /etc/oracle-release .
uname -a > uname-a
#rhn_check >> rhn_check 2>&1
subscription-manager status >> subscription-manager-status 2>&1

echo "3.2.2---------" 
cp -v /etc/grub.conf .

echo "3.2.3--------"
cp -v /etc/modprobe.conf .
lsmod >> lsmod
cp -v /proc/sys/kernel/tainted .

echo "3.2.4--------"
rpm -qa >> rpm-qa
yum list >> yum-list 2>&1
yum grouplist > yum-grouplist 2>&1
yum info-security | grep Critical >> Critical-updates 2>&1
yum check-update > yum-check-update 2>&1
yum check-update --security > yum-check-update-security 2>&1
cp -rv /etc/yum.repos.d .

###########################
cd .. && mkdir 3.3 && cd 3.3
touch 3.3-Access

echo "3.3.1--------"
cp -v /etc/ssh/sshd_config .
cat /etc/ssh/sshd_config|grep -i PermitRootLogin >> sshd_config_root_login
cat /etc/ssh/sshd_config|grep -i Client* >> ssh_session_timeout

echo "3.3.2--------"
cp -v /etc/pam.d/system-auth .

echo "3.3.3 --------"
cp -v /etc/sudoers .

###########################
cd .. && mkdir 3.4 && cd 3.4
touch 3.4-Storage-Configurations

echo "3.4.1 --------"
lsblk -l > lsblk
blkid > blkid
lsscsi -v > lsscsi-v
cat /proc/scsi/scsi >> proc-scsi
parted --list >> parted-list
sfdisk -l >> sfdisk-l
dmesg | grep -i "attached" >> Storage-disks
ls -l /dev/disk/by-path/ >> disk-by-path

echo "3.4.2 --------"
cp -v /etc/multipath.conf .

echo "3.4.3 --------"
mount > mount 2>&1
vgdisplay > vgdisplay 2>&1
lvdisplay > lvdisplay 2>&1

echo "3.4.4 --------"
df -hT >> df-hT
df -i >> df-i

echo "3.4.5 --------"
cp -v /etc/fstab .

###########################
cd .. && mkdir 3.5 && cd 3.5
touch 3.5-Network-Configuration

echo "3.5.1 --------" 
ifconfig -a >> ifconfig-a
ethtool eth0 > ethtool-eth0
ethtool eth1 > ethtool-eth1
ethtool eth2 > ethtool-eth2
ethtool eth3 > ethtool-eth3
arp -e >> arp-e
netstat -r >> netstat-r
netstat -i >> netstat-i
netstat -s >> netstat-s
cat /proc/net/dev >> proc-net-dev
route >> route
ip link show >> ip-link-show
netstat -ulnp >> netstat-ulnp
netstat -tlnp >> netstat-tlnp
lsof >> lsof
ip -s link show eth0 >> eth0-link-status
ip route show | grep default
echo "3.5.2 --------"
cp -v /etc/sysconfig/network-scripts/ifcfg-* .

###########################
cd .. && mkdir 3.6 && cd 3.6
touch 3.6-Network-Services

echo "3.6.1 --------"
chkconfig --list >> chkconfig

echo "3.6.2 --------"
date >> date
ntpstat >> ntpstat
hwclock >> hwclock

echo "3.6.3 --------"
cat /etc/grub.conf|grep -i crashkernel >> kdump

echo "3.6.4 --------"
cp -v /etc/syslog.conf .
cp -v /etc/rsyslog.conf .

###########################
cd .. && mkdir 3.7 && cd 3.7
touch 3.7-Kenel-Parameters

echo "3.7.1 --------"
grep Hugepagesize /proc/meminfo >> hugepagesize
cat /proc/meminfo >> meminfo

echo "3.7.2 --------"
cp -v /etc/sysctl.conf .

echo "3.7.3 --------"
cp -v /boot/grub/grub.conf .
cat /etc/grub.conf |grep -i elevator >> io-scheduler

echo "3.7.4 --------"
cat /etc/grub.conf|grep -i nousb >> target-security-policy


###########################
cd .. && mkdir 3.8 && cd 3.8
touch 3.8-Security

echo "3.8.1 --------"
sestatus >> sestatus

echo "3.8.2 --------"
chkconfig --list iptables >> iptables-chk
iptables -L >> iptables-L
cp -v /etc/sysconfig/iptables .

echo "3.8.3 --------"
cp -v /etc/hosts.allow .
cp -v /etc/hosts.deny .


###########################
cd .. && mkdir 3.9 && cd 3.9
touch 3.9-Monitoring-and-Mangeability

echo "3.9.1 --------"
echo "Sar utility Analyze"

echo "3.9.2 --------"
cat /etc/sysconfig/rhn/up2date |grep -i xmlrpc >> rhn-server

echo "3.9.3 --------"
echo "Check if client has staging environment"

echo "3.9.4 --------"
echo "Check how the server backup policy"

###########################
cd .. && mkdir 3.10 && cd 3.10
touch 3.10-Performance-Analysis

echo "3.10.1 --------"
uptime >> uptime

echo "3.10.2 --------"
df -h >>df-h
df -i >>df-i

echo "3.10.3 --------" 
sar -u 1 3 >> sar-cpu
sar -P ALL 1 1 >> sar-cpu-proc
sar -q 3 3 >> sar-cpu-load
sar -r 1 3 >> sar-memory
#sar -S 1 3 >> sar-memory-swap
sar -b 1 3 >> sar-io
sar -p -d 1 1 >> sar-disk
sar -n DEV 1 1 >> sar-network-DEV
sar -n ALL 3 3 >> sar-network-ALL
cp -rv /var/log/sa .


cat /var/log/secure* |egrep -i 'failed|error|invalid|warning' >> secure-failed
cat /var/log/messages* |egrep -i 'failed|error|memory|invalid' >> messages-failed
cp -v /var/log/messages .
cp -v /var/log/secure .
cp -v /var/log/dmesg .
cp -v /var/log/audit/audit.log .
mpstat -P ALL >> mpstat-all
iostat -x >> iostat
lscpu >> lscpu
cp -rv /var/spool/cron .
cp -rv /etc/cron* .
###########################
cd /home/bb_02570
tar -cvzf kuwaitnet-rhc-`hostname`.tgz kuwaitnet-rhc-`hostname` ; chown bb_02570. kuwaitnet-rhc-`hostname`.tgz

exit 0
